local RS = game:GetService("ReplicatedStorage")
local Remotes = require(RS.Remotes)
local DataService = require(script.Parent.DataService)
local LobeService = require(script.Parent.LobeService)
local HudNotify = require(script.Parent.HudNotify)

local MindBlockService = {}

local COOLDOWN = 90
local cooldownUntil = {}

function MindBlockService.Duration(player: Player)
	return 60 + 6 * DataService.Get(player).Upgrades.Defense
end

function MindBlockService.Activate(player: Player)
	local lobe = LobeService.LobeOf(player)
	if not lobe then
		return
	end
	if (cooldownUntil[player] or 0) > os.clock() then
		HudNotify.PopupOver(player, "MIND BLOCK RECHARGING", Color3.fromRGB(200, 200, 200))
		return
	end
	local duration = MindBlockService.Duration(player)
	lobe.MindBlockUntil = os.clock() + duration
	cooldownUntil[player] = os.clock() + duration + COOLDOWN
	lobe.Model.MindBlockField.Transparency = 0.35
	HudNotify.Popup(nil, "MIND BLOCK! 🛡️", Color3.fromRGB(255, 90, 200), lobe.CF.Position + Vector3.new(0, 18, 0), true)
	HudNotify.Feed(player, "🛡️ Mind Block up for " .. duration .. "s. Nobody steals from this brain.")
	DataService.Bump(player, "MindBlocks", 1)
end

local function pushOutIntruders(lobe)
	for _, other in game:GetService("Players"):GetPlayers() do
		local root = other ~= lobe.Owner and other.Character and other.Character:FindFirstChild("HumanoidRootPart")
		if root and LobeService.Contains(lobe, root.Position) then
			other.Character:PivotTo(lobe.CF * CFrame.new(0, 4, -22) * CFrame.Angles(0, math.pi, 0))
			HudNotify.PopupOver(other, "BONK! MIND BLOCKED", Color3.fromRGB(255, 90, 200))
		end
	end
end

function MindBlockService.Start()
	Remotes.OnRequest("MindBlock", MindBlockService.Activate)
	DataService.AddStateField(function(player, s)
		local lobe = LobeService.LobeOf(player)
		s.MindBlockLeft = lobe and math.max(0, (lobe.MindBlockUntil or 0) - os.clock()) or 0
		s.MindBlockCd = math.max(0, (cooldownUntil[player] or 0) - os.clock() - s.MindBlockLeft)
	end)
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		cooldownUntil[player] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(0.3)
			for _, lobe in LobeService.Lobes do
				local field = lobe.Model.MindBlockField
				if (lobe.MindBlockUntil or 0) > os.clock() then
					field.Transparency = 0.25 + 0.15 * math.sin(os.clock() * 4)
					pushOutIntruders(lobe)
				elseif field.Transparency < 1 then
					field.Transparency = 1
				end
			end
		end
	end)
end

return MindBlockService
