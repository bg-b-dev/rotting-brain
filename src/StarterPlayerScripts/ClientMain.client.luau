local CONTROLLERS = {
	"ClientState", "InputController", "HudController", "MemePopups", "CarryController",
	"UpgradeUI", "BrainWashUI", "BrainpediaUI", "CatchCardUI",
}

for _, name in CONTROLLERS do
	require(script.Parent:WaitForChild(name)).Start()
end
