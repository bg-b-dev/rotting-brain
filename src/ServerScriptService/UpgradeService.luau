local RS = game:GetService("ReplicatedStorage")
local UpgradeConfig = require(RS.UpgradeConfig)
local NumberFormat = require(RS.NumberFormat)
local Remotes = require(RS.Remotes)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local LobeService = require(script.Parent.LobeService)
local CarryService = require(script.Parent.CarryService)
local HudNotify = require(script.Parent.HudNotify)

local UpgradeService = {}

function UpgradeService.Buy(player: Player, groupId: string)
	local p = DataService.Get(player)
	local tier = p and p.Upgrades[groupId]
	if not tier or tier >= UpgradeConfig.MaxTier then
		return
	end
	local cost = UpgradeConfig.Cost(groupId, tier + 1)
	if not Economy.TrySpend(player, cost) then
		return
	end
	p.Upgrades[groupId] = tier + 1
	DataService.Bump(player, "Upgrades", 1)
	HudNotify.PopupOver(player, string.upper(groupId) .. " LV " .. (tier + 1) .. "! SIGMA", Color3.fromRGB(255, 215, 70), true)
	if groupId == "Speed" then
		CarryService.ApplySpeed(player)
	elseif groupId == "Thoughts" then
		local lobe = LobeService.LobeOf(player)
		if lobe then
			LobeService.ApplyTier(lobe)
		end
	end
end

local function openAtKiosk(kioskName: string, ui: string)
	local counter = workspace.BrainWorld.DopamineMart[kioskName].Counter
	counter.Prompt.Triggered:Connect(function(player)
		Remotes.Fire("OpenUI", player, ui)
	end)
end
UpgradeService.OpenAtKiosk = openAtKiosk

function UpgradeService.Start()
	Remotes.OnRequest("BuyUpgrade", UpgradeService.Buy)
	openAtKiosk("UpgradeKiosk", "Upgrades")
	DataService.AddStateField(function(_, s, p)
		s.Upgrades = p.Upgrades
		s.UpgradeCosts = {}
		for _, g in UpgradeConfig.Groups do
			local tier = p.Upgrades[g.Id]
			s.UpgradeCosts[g.Id] = tier < UpgradeConfig.MaxTier and NumberFormat.Cells(UpgradeConfig.Cost(g.Id, tier + 1)) or "MAX"
		end
	end)
end

return UpgradeService
