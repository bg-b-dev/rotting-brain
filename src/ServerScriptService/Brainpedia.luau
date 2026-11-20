local RS = game:GetService("ReplicatedStorage")
local BrainrotCatalog = require(RS.BrainrotCatalog)
local Remotes = require(RS.Remotes)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)

local Brainpedia = {}

function Brainpedia.Record(player: Player, entry, source: string?)
	local p = DataService.Get(player)
	if not p then
		return
	end
	local key = tostring(entry.Id)
	local isNew = p.Pedia[key] == nil
	p.Pedia[key] = p.Pedia[key] or {}
	p.Pedia[key][entry.Mut or "Normal"] = true
	if isNew then
		local found = Economy.FoundCount(p)
		local def = BrainrotCatalog.Get(entry.Id)
		Remotes.Fire("CatchCard", player, { Id = entry.Id, Mut = entry.Mut, Lv = entry.Lv or 1, Found = found, Source = source })
		HudNotify.Feed(player, "📖 NEW BRAINROT! " .. def.Name .. " (" .. found .. "/60)")
		if found % 10 == 0 then
			HudNotify.PopupOver(player, "MILESTONE! +10% INCOME", Color3.fromRGB(255, 215, 70), true)
		end
		DataService.Bump(player, "Discovered", 1)
	end
	Remotes.Fire("Pedia", player, p.Pedia)
end

function Brainpedia.Start()
	GameSignals.On("Acquired", Brainpedia.Record)
	GameSignals.On("PlayerReady", function(player)
		Remotes.Fire("Pedia", player, DataService.Get(player).Pedia)
	end)
	DataService.AddStateField(function(_, s, p)
		s.Found = Economy.FoundCount(p)
	end)
end

return Brainpedia
