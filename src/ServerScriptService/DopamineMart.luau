local RS = game:GetService("ReplicatedStorage")
local Remotes = require(RS.Remotes)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local CarryService = require(script.Parent.CarryService)
local ThoughtBubbleHatch = require(script.Parent.ThoughtBubbleHatch)
local UpgradeService = require(script.Parent.UpgradeService)
local HudNotify = require(script.Parent.HudNotify)

local DopamineMart = {}

DopamineMart.Gear = {
	SlapperSupremo = { Name = "Slapper Supremo", Price = 5e3, Text = "Bigger slap area, double bounty" },
	SigmaSneakers = { Name = "Sigma Sneakers", Price = 2e4, Text = "+40% walk speed" },
	NoodleArm = { Name = "Noodle Arm", Price = 5e4, Text = "Longer buy and steal reach" },
	RizzMagnet = { Name = "Rizz Magnet", Price = 2.5e5, Text = "Collects income without a walk home" },
	EnergyDrink = { Name = "Energy Drink", Price = 1e4, Text = "+15% luck for 5 minutes", Consumable = true },
}

function DopamineMart.BuyGear(player: Player, id: string)
	local p = DataService.Get(player)
	local gear = DopamineMart.Gear[id]
	if not (p and gear) or (p.Gear[id] and not gear.Consumable) then
		return
	end
	if not Economy.TrySpend(player, gear.Price) then
		return
	end
	if gear.Consumable then
		Economy.AddBuff(player, "Energy Drink", 300)
	else
		p.Gear[id] = true
	end
	CarryService.ApplySpeed(player)
	DataService.Bump(player, "GearBought", 1)
	HudNotify.PopupOver(player, string.upper(gear.Name) .. "! +DOPAMINE", Color3.fromRGB(255, 215, 70), true)
end

function DopamineMart.BuyBubble(player: Player, kind: string)
	ThoughtBubbleHatch.Add(player, kind)
end

function DopamineMart.Start()
	Remotes.OnRequest("BuyGear", DopamineMart.BuyGear)
	Remotes.OnRequest("BuyBubble", DopamineMart.BuyBubble)
	UpgradeService.OpenAtKiosk("GearKiosk", "Mart")
	DataService.AddStateField(function(_, s, p)
		s.Gear = p.Gear
	end)
end

return DopamineMart
