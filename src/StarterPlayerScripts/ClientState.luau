local Remotes = require(game:GetService("ReplicatedStorage").Remotes)

local ClientState = {
	State = {},
	Pedia = {},
	Changed = Instance.new("BindableEvent"),
	PediaChanged = Instance.new("BindableEvent"),
}

function ClientState.Start()
	Remotes.Get("State").OnClientEvent:Connect(function(state)
		ClientState.State = state
		ClientState.Changed:Fire(state)
	end)
	Remotes.Get("Pedia").OnClientEvent:Connect(function(pedia)
		ClientState.Pedia = pedia
		ClientState.PediaChanged:Fire(pedia)
	end)
end

return ClientState
