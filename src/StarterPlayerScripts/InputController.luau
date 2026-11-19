local ContextActionService = game:GetService("ContextActionService")
local Remotes = require(game:GetService("ReplicatedStorage").Remotes)

local InputController = { Handlers = {} }

InputController.Keys = {
	{ Key = "L", Code = Enum.KeyCode.L, Label = "Mind Block", Icon = "🛡️" },
	{ Key = "F", Code = Enum.KeyCode.F, Label = "Focus Slap", Icon = "✋" },
	{ Key = "G", Code = Enum.KeyCode.G, Label = "Blend", Icon = "🍝" },
	{ Key = "U", Code = Enum.KeyCode.U, Label = "Upgrades", Icon = "⬆️" },
	{ Key = "R", Code = Enum.KeyCode.R, Label = "Brain Wash", Icon = "🧼" },
	{ Key = "B", Code = Enum.KeyCode.B, Label = "Brainpedia", Icon = "📖" },
	{ Key = "H", Code = Enum.KeyCode.H, Label = "Mart", Icon = "💊" },
}

function InputController.Register(key: string, fn)
	InputController.Handlers[key] = fn
end

function InputController.Trigger(key: string)
	local fn = InputController.Handlers[key]
	if fn then
		fn()
	end
end

function InputController.Start()
	InputController.Register("L", function()
		Remotes.Send("MindBlock")
	end)
	InputController.Register("F", function()
		Remotes.Send("FocusSlap")
	end)
	for _, k in InputController.Keys do
		ContextActionService:BindAction("RottingBrain" .. k.Key, function(_, inputState)
			if inputState == Enum.UserInputState.Begin then
				InputController.Trigger(k.Key)
			end
			return Enum.ContextActionResult.Sink
		end, false, k.Code)
	end
end

return InputController
