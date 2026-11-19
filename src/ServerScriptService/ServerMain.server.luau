local SSS = game:GetService("ServerScriptService")

require(SSS.WorldBuilder).BuildWorld()

local SERVICES = {
	"DataService", "BrainCellEconomy", "LobeService", "CarryService", "SynapseBelt", "StealService",
	"MindBlockService", "FocusSlapService", "ProductivityPixieRaid", "BrainFogCannon", "MutationService",
	"RotMeter", "TouchGrassWave", "EventScheduler", "UpgradeService",
	"BrainWashRebirth", "Brainpedia", "MemeBlender", "ThoughtBubbleHatch",
	"MostRottedBoard", "DopamineMart", "BrainWheel", "BrainTasks",
	"DailyRewards", "PetFollower", "SubconsciousGate", "BrainTeaserCorner", "NpcKids",
	"AwakeRemCycle", "PlaytestControls",
}

for _, name in SERVICES do
	local ok, err = pcall(function()
		local service = require(SSS[name])
		if service.Start then
			service.Start()
		end
	end)
	if not ok then
		warn(name .. " failed to start: " .. tostring(err))
	end
end

require(SSS.DataService).Begin()
