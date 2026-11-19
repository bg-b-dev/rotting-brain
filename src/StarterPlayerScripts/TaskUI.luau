local UiKit = require(script.Parent.UiKit)
local ClientState = require(script.Parent.ClientState)

local C = UiKit.Colors

local TaskUI = {}

function TaskUI.Start()
	local _, root = UiKit.Screen("BrainTasks", 2)
	local panel = UiKit.Frame(root, { Name = "Tasks", Size = UDim2.fromOffset(270, 196), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 236), Stroke = C.Cyan })
	UiKit.Label(panel, { Size = UDim2.new(1, -16, 0, 26), Position = UDim2.fromOffset(8, 4), Text = "🧠 BRAIN TASKS", TextColor3 = C.Cyan, TextXAlignment = Enum.TextXAlignment.Left })
	local rows = {}
	for i = 1, 3 do
		local y = 34 + (i - 1) * 54
		local text = UiKit.Label(panel, { Size = UDim2.new(1, -16, 0, 30), Position = UDim2.fromOffset(8, y), Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true })
		local bar = UiKit.Frame(panel, { Size = UDim2.new(1, -16, 0, 12), Position = UDim2.fromOffset(8, y + 34), BackgroundColor3 = Color3.fromRGB(15, 5, 20), BackgroundTransparency = 0, Corner = 6 })
		local fill = UiKit.Frame(bar, { Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.Goo, BackgroundTransparency = 0, Corner = 6 })
		rows[i] = { Text = text, Fill = fill }
	end
	ClientState.Changed.Event:Connect(function(s)
		for i, row in rows do
			local t = (s.Tasks or {})[i]
			row.Text.Text = t and (t.Text .. " " .. t.Progress .. "/" .. t.Goal) or ""
			row.Fill.Size = UDim2.fromScale(t and t.Progress / t.Goal or 0, 1)
		end
	end)
end

return TaskUI
