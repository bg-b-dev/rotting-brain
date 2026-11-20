local RS = game:GetService("ReplicatedStorage")
local BrainrotCatalog = require(RS.BrainrotCatalog)
local DataService = require(script.Parent.DataService)
local CarryService = require(script.Parent.CarryService)
local LobeService = require(script.Parent.LobeService)
local HudNotify = require(script.Parent.HudNotify)

local StealService = {}

function StealService.IsBlocked(lobe)
	return (lobe.MindBlockUntil or 0) > os.clock()
end

function StealService.TrySteal(player: Player, lobe, idx: number)
	if lobe.Owner == player or not DataService.Get(player) then
		return
	end
	if StealService.IsBlocked(lobe) then
		HudNotify.PopupOver(player, "MIND BLOCKED! 🛡️", Color3.fromRGB(255, 90, 200), true)
		return
	end
	if CarryService.IsFull(player) then
		HudNotify.PopupOver(player, "HANDS FULL!", Color3.fromRGB(255, 200, 60))
		return
	end
	local entry = LobeService.RemoveEntry(lobe, idx)
	if not entry then
		return
	end
	local def = BrainrotCatalog.Get(entry.Id)
	CarryService.PickUp(player, entry, { Lobe = lobe, OwnerUserId = lobe.Owner and lobe.Owner.UserId })
	DataService.Bump(player, "Stolen", 1)
	HudNotify.PopupOver(player, "SNEAKY! +RIZZ", Color3.fromRGB(255, 110, 200), true)
	HudNotify.Alert(player, "🦹 STOLEN! RUN HOME!", Color3.fromRGB(255, 70, 80))
	HudNotify.Feed(player, "🦹 You grabbed " .. def.Name .. ". Run home before they slap you!")
	if lobe.Owner then
		HudNotify.Alert(lobe.Owner, "🚨 STOLEN! SLAP THEM [F]", Color3.fromRGB(255, 70, 80))
		HudNotify.Feed(lobe.Owner, "🚨 " .. player.DisplayName .. " is stealing your " .. def.Name .. "! Press [F] to Focus Slap!")
	end
end

function StealService.Start()
	LobeService.StealHandler = StealService.TrySteal
end

return StealService
