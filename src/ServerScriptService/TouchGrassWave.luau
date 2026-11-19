local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local BrainrotModelKit = require(RS.BrainrotModelKit)
local WorldBuilder = require(script.Parent.WorldBuilder)
local DataService = require(script.Parent.DataService)
local CarryService = require(script.Parent.CarryService)
local HudNotify = require(script.Parent.HudNotify)

local TouchGrassWave = { Active = false }

local WAVE = { Width = 420, Height = 50, Blades = 90, Flowers = 36, Duration = 8, From = -230, To = 230, SafeY = 10 }
local FLOWER_COLORS = { Color3.fromRGB(255, 240, 80), Color3.fromRGB(255, 120, 200), Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 90, 90) }

local function buildWave()
	local m = Instance.new("Model")
	m.Name = "TouchGrassWave"
	local core = WorldBuilder.Part(m, { Name = "Core", Size = Vector3.new(4, WAVE.Height * 0.6, WAVE.Width), Position = Vector3.new(0, WAVE.Height * 0.3, 0), Color = WorldBuilder.Colors.Grass, Material = Enum.Material.Grass, CanCollide = false, CanQuery = false })
	m.PrimaryPart = core
	local rng = Random.new(77)
	for _ = 1, WAVE.Blades do
		local h = rng:NextNumber(WAVE.Height * 0.5, WAVE.Height)
		local z = rng:NextNumber(-WAVE.Width / 2, WAVE.Width / 2)
		WorldBuilder.Part(m, { Name = "GrassBlade", Class = "WedgePart", Size = Vector3.new(2, h, rng:NextNumber(5, 9)), CFrame = CFrame.new(rng:NextNumber(-3, 3), h / 2, z) * CFrame.Angles(0, math.rad(90), rng:NextNumber(-0.25, 0.25)), Color = WorldBuilder.Colors.Grass:Lerp(Color3.fromRGB(30, 120, 30), rng:NextNumber(0, 0.6)), Material = Enum.Material.Grass, CanCollide = false, CanQuery = false })
	end
	for _ = 1, WAVE.Flowers do
		local pos = Vector3.new(4, rng:NextNumber(4, WAVE.Height * 0.8), rng:NextNumber(-WAVE.Width / 2, WAVE.Width / 2))
		WorldBuilder.Part(m, { Name = "Flower", Shape = Enum.PartType.Ball, Size = Vector3.one * rng:NextNumber(2.5, 4), Position = pos, Color = FLOWER_COLORS[rng:NextInteger(1, #FLOWER_COLORS)], Material = Enum.Material.Neon, CanCollide = false, CanQuery = false })
	end
	for _, z in { -120, 0, 120 } do
		local sign = WorldBuilder.Part(m, { Name = "TouchGrassSign", Size = Vector3.new(1, 12, 60), Position = Vector3.new(6, WAVE.Height * 0.55, z), Color = WorldBuilder.Colors.Grass, Transparency = 1, CanCollide = false, CanQuery = false })
		WorldBuilder.Label(sign, "🌱 TOUCH GRASS! 🌱", { Face = Enum.NormalId.Right, Color = Color3.new(1, 1, 1), Font = Enum.Font.LuckiestGuy, Stroke = 0 })
		WorldBuilder.Label(sign, "🌱 TOUCH GRASS! 🌱", { Face = Enum.NormalId.Left, Color = Color3.new(1, 1, 1), Font = Enum.Font.LuckiestGuy, Stroke = 0 })
	end
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") and p ~= core then
			local w = Instance.new("WeldConstraint")
			w.Part0 = core
			w.Part1 = p
			w.Parent = p
		end
	end
	m:PivotTo(CFrame.new(WAVE.From, 0, 0))
	return m
end

local function knockDown(player: Player, dir: number)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not (humanoid and root) then
		return
	end
	CarryService.Drop(player, "touched grass")
	humanoid.PlatformStand = true
	root.AssemblyLinearVelocity = Vector3.new(dir * 60, 35, 0)
	HudNotify.PopupOver(player, "TOUCHED GRASS! 🤮", Color3.fromRGB(90, 220, 90), true)
	DataService.Bump(player, "GrassTouched", 1)
	task.delay(1.6, function()
		if humanoid.Parent then
			humanoid.PlatformStand = false
		end
	end)
end

function TouchGrassWave.Run()
	if TouchGrassWave.Active then
		return
	end
	TouchGrassWave.Active = true
	local wave = buildWave()
	wave.Parent = workspace
	local set = BrainrotModelKit.MakeGlider(wave)
	wave.PrimaryPart:SetNetworkOwner(nil)
	local hit = {}
	local x, prevX = WAVE.From, WAVE.From
	local speed = (WAVE.To - WAVE.From) / WAVE.Duration
	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		prevX, x = x, x + speed * dt
		set(CFrame.new(x, 0, 0))
		for _, player in Players:GetPlayers() do
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root and not hit[player] and root.Position.X > prevX - 3 and root.Position.X <= x + 3 then
				hit[player] = true
				if root.Position.Y < WAVE.SafeY then
					knockDown(player, 1)
				else
					HudNotify.PopupOver(player, "SAFE! GRASS AVOIDED", Color3.fromRGB(255, 158, 199), true)
					DataService.Bump(player, "WavesSurvived", 1)
				end
			end
		end
	end)
	task.wait(WAVE.Duration)
	conn:Disconnect()
	wave:Destroy()
	TouchGrassWave.Active = false
end

function TouchGrassWave.Start() end

return TouchGrassWave
