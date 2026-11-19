local CONTROLLERS = {
	"ClientState", "InputController", "HudController", "MemePopups", "CarryController",
}

for _, name in CONTROLLERS do
	require(script.Parent:WaitForChild(name)).Start()
end
