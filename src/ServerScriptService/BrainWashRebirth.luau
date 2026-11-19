local RS = game:GetService("ReplicatedStorage")
local UpgradeConfig = require(RS.UpgradeConfig)
local NumberFormat = require(RS.NumberFormat)
local Remotes = require(RS.Remotes)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local LobeService = require(script.Parent.LobeService)
local CarryService = require(script.Parent.CarryService)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)
local UpgradeService = require(script.Parent.UpgradeService)

local BrainWashRebirth = {}

function BrainWashRebirth.Wash(player: Player)
	local p = DataService.Get(player)
	local nextWash = p and UpgradeConfig.Washes[p.Washes + 1]
	if not nextWash then
		return
	end
	if not Economy.TrySpend(player, nextWash.Cost) then
		return
	end
	CarryService.Drop(player, "brain washed")
	local lobe = LobeService.LobeOf(player)
	if lobe then
		LobeService.ClearAll(lobe)
	end
	p.Podiums = {}
	if lobe then
		lobe.Entries = p.Podiums
	end
	p.Bubbles = {}
	for id in p.Upgrades do
		p.Upgrades[id] = 0
	end
	p.Washes += 1
	p.AuraPoints += p.Washes
	p.Cells = p.Perks.HeadStart and 1e4 or 100
	DataService.Rt(player).Bank = 0
	CarryService.ApplySpeed(player)
	if lobe then
		LobeService.ApplyTier(lobe)
	end
	DataService.Bump(player, "Washes", 1)
	HudNotify.PopupOver(player, "BRAIN WASHED! x" .. nextWash.Mult, Color3.fromRGB(70, 225, 255), true)
	HudNotify.Feed(nil, "🧼 " .. player.DisplayName .. " reached Brain Wash " .. p.Washes .. "! Unlocked: " .. nextWash.Unlock)
	GameSignals.Emit("BrainWashed", player, p.Washes)
end

function BrainWashRebirth.BuyPerk(player: Player, perkId: string)
	local p = DataService.Get(player)
	for _, perk in UpgradeConfig.Perks do
		if perk.Id == perkId and not p.Perks[perkId] and p.AuraPoints >= perk.Cost then
			p.AuraPoints -= perk.Cost
			p.Perks[perkId] = true
			HudNotify.PopupOver(player, "+" .. string.upper(perk.Name) .. " · AURA", Color3.fromRGB(255, 255, 255), true)
			return
		end
	end
end

function BrainWashRebirth.Start()
	Remotes.OnRequest("BrainWash", BrainWashRebirth.Wash)
	Remotes.OnRequest("BuyPerk", BrainWashRebirth.BuyPerk)
	UpgradeService.OpenAtKiosk("BrainWashKiosk", "BrainWash")
	DataService.AddStateField(function(_, s, p)
		s.AuraPoints = p.AuraPoints
		s.Perks = p.Perks
		local nextWash = UpgradeConfig.Washes[p.Washes + 1]
		s.NextWash = nextWash and { Cost = NumberFormat.Cells(nextWash.Cost), Mult = nextWash.Mult, Unlock = nextWash.Unlock, Ready = p.Cells >= nextWash.Cost } or nil
	end)
end

return BrainWashRebirth
