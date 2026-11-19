local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Remotes = require(RS.Remotes)
local DataService = require(script.Parent.DataService)
local CarryService = require(script.Parent.CarryService)
local HudNotify = require(script.Parent.HudNotify)

local FocusSlapService = {}

local COOLDOWN = 1.2
local STUN = 2
local lastSlap = {}

function FocusSlapService.Reach(player: Player)
	return DataService.Get(player).Gear.SlapperSupremo and 16 or 10
end

local function stun(victim: Player)
	local rt = DataService.Rt(victim)
	local humanoid = victim.Character and victim.Character:FindFirstChildOfClass("Humanoid")
	if not (rt and humanoid) or rt.Stunned then
		return
	end
	rt.Stunned = true
	CarryService.Drop(victim, "focus slapped")
	humanoid.PlatformStand = true
	local root = victim.Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.AssemblyLinearVelocity = Vector3.new(math.random(-20, 20), 30, math.random(-20, 20))
	end
	task.delay(STUN, function()
		rt.Stunned = false
		if humanoid.Parent then
			humanoid.PlatformStand = false
		end
		CarryService.ApplySpeed(victim)
	end)
end

function FocusSlapService.Slap(player: Player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or (lastSlap[player] or 0) + COOLDOWN > os.clock() then
		return
	end
	lastSlap[player] = os.clock()
	local reach = FocusSlapService.Reach(player)
	HudNotify.Popup(nil, "✋ SLAP!", Color3.fromRGB(255, 230, 120), root.Position + root.CFrame.LookVector * 3 + Vector3.new(0, 2, 0))
	local hits = require(script.Parent.ProductivityPixieRaid).SlapNear(player, root.Position, reach)
	for _, other in Players:GetPlayers() do
		local oroot = other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart")
		if oroot and (oroot.Position - root.Position).Magnitude <= reach then
			local ort = DataService.Rt(other)
			if ort and #ort.Carrying > 0 then
				hits += 1
				stun(other)
				DataService.Bump(player, "SlappedThieves", 1)
				HudNotify.Feed(player, "✋ You Focus Slapped " .. other.DisplayName .. ". Sigma move.")
			end
		end
	end
	if hits > 0 then
		DataService.Bump(player, "Slaps", hits)
	end
end

function FocusSlapService.Start()
	Remotes.OnRequest("FocusSlap", FocusSlapService.Slap)
	DataService.AddStateField(function(player, s)
		s.SlapCd = math.max(0, (lastSlap[player] or 0) + COOLDOWN - os.clock())
	end)
	Players.PlayerRemoving:Connect(function(player)
		lastSlap[player] = nil
	end)
end

return FocusSlapService
