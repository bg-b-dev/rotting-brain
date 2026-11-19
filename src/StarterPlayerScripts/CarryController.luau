local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ClientState = require(script.Parent.ClientState)

local CarryController = {}

local player = Players.LocalPlayer

local function ownLobe()
	local world = workspace:FindFirstChild("BrainWorld")
	if not world then
		return nil
	end
	for i = 1, 8 do
		local lobe = world:FindFirstChild("Lobe" .. i)
		if lobe and lobe:GetAttribute("OwnerUserId") == player.UserId then
			return lobe
		end
	end
	return nil
end

local guide

local function updateGuide(state)
	local carrying = #(state.Carrying or {}) > 0
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local lobe = ownLobe()
	if not (carrying and root and lobe) then
		if guide then
			guide.Enabled = false
		end
		return
	end
	if not guide or not guide.Parent then
		local a0 = Instance.new("Attachment")
		a0.Name = "CarryGuideStart"
		local a1 = Instance.new("Attachment")
		a1.Name = "CarryGuideEnd"
		a1.Parent = workspace.Terrain
		guide = Instance.new("Beam")
		guide.Attachment0 = a0
		guide.Attachment1 = a1
		guide.Width0 = 1.2
		guide.Width1 = 1.2
		guide.FaceCamera = true
		guide.Color = ColorSequence.new(Color3.fromRGB(130, 255, 80))
		guide.LightEmission = 1
		guide.Transparency = NumberSequence.new(0.3)
		guide.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		guide.TextureSpeed = 2
		guide.Parent = workspace.Terrain
	end
	guide.Attachment0.Parent = root
	guide.Attachment1.WorldPosition = lobe.CollectPad.Position + Vector3.new(0, 2, 0)
	guide.Enabled = true
end

local function hideOwnStealPrompts()
	local lobe = ownLobe()
	if lobe then
		for _, d in lobe:GetDescendants() do
			if d:IsA("ProximityPrompt") and d.Name == "StealPrompt" then
				d.Enabled = false
			end
		end
	end
end

local jitter = {}

function CarryController.Start()
	ClientState.Changed.Event:Connect(function(state)
		updateGuide(state)
		hideOwnStealPrompts()
	end)
	workspace.DescendantAdded:Connect(function(d)
		if d:IsA("Model") and d:GetAttribute("Jitter") then
			jitter[d] = true
		end
	end)
	local last = 0
	RunService.RenderStepped:Connect(function()
		if os.clock() - last < 0.08 then
			return
		end
		last = os.clock()
		for m in jitter do
			if not m.Parent then
				jitter[m] = nil
			elseif m.PrimaryPart and m.PrimaryPart.Anchored then
				local base = m:GetAttribute("JitterBase") or m:GetPivot()
				m:SetAttribute("JitterBase", base)
				m:PivotTo(base * CFrame.new(math.random(-10, 10) / 40, math.random(-10, 10) / 40, 0) * CFrame.Angles(0, math.random(-10, 10) / 60, 0))
			end
		end
	end)
end

return CarryController
