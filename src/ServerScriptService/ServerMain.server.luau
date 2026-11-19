local SSS = game:GetService("ServerScriptService")

require(SSS.WorldBuilder).BuildWorld()

local SERVICES = {
	"DataService", "BrainCellEconomy", "LobeService", "CarryService", "SynapseBelt", "PlaytestControls",
}

for _, name in SERVICES do
	local service = require(SSS[name])
	if service.Start then
		service.Start()
	end
end

require(SSS.DataService).Begin()
