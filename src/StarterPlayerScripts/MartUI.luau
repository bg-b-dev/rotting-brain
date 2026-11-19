local RS = game:GetService("ReplicatedStorage")
local NumberFormat = require(RS.NumberFormat)
local Remotes = require(RS.Remotes)
local UiKit = require(script.Parent.UiKit)
local ClientState = require(script.Parent.ClientState)
local InputController = require(script.Parent.InputController)

local C = UiKit.Colors

local MartUI = {}

local GEAR = {
	{ Id = "SlapperSupremo", Icon = "✋", Name = "Slapper Supremo", Price = 5e3, Text = "Bigger slap, x2 bounty" },
	{ Id = "SigmaSneakers", Icon = "👟", Name = "Sigma Sneakers", Price = 2e4, Text = "+40% walk speed" },
	{ Id = "NoodleArm", Icon = "🍜", Name = "Noodle Arm", Price = 5e4, Text = "Longer buy reach" },
	{ Id = "RizzMagnet", Icon = "🧲", Name = "Rizz Magnet", Price = 2.5e5, Text = "Auto-collect income" },
	{ Id = "EnergyDrink", Icon = "⚡", Name = "Energy Drink", Price = 1e4, Text = "+15% luck, 5 min", Consumable = true },
}
local BUBBLES = {
	{ Kind = "Basic", Icon = "💭", Price = 500, Text = "30s · Common+" },
	{ Kind = "Gold", Icon = "🌕", Price = 5e4, Text = "2m · Rare+ · Wash 1" },
	{ Kind = "Galaxy", Icon = "🌌", Price = 5e6, Text = "5m · Legendary+ · Wash 3" },
}

local function card(parent, x, y, icon, name, text, color)
	local f = UiKit.Frame(parent, { Size = UDim2.fromOffset(140, 170), Position = UDim2.fromOffset(x, y), BackgroundColor3 = C.PanelLight, Stroke = color })
	UiKit.Label(f, { Size = UDim2.new(1, 0, 0, 40), Position = UDim2.fromOffset(0, 4), Text = icon })
	UiKit.Label(f, { Size = UDim2.new(1, -10, 0, 22), Position = UDim2.fromOffset(5, 46), Text = name, TextColor3 = color })
	UiKit.Label(f, { Size = UDim2.new(1, -10, 0, 36), Position = UDim2.fromOffset(5, 70), Text = text, TextColor3 = C.Gray, TextWrapped = true })
	return f
end

function MartUI.Start()
	local win, content = UiKit.Window("Mart", "💊 DOPAMINE MART · GEAR + THOUGHT BUBBLES", Vector2.new(780, 470), C.Yellow)
	local gearButtons = {}
	for i, g in GEAR do
		local f = card(content, (i - 1) * 148, 0, g.Icon, g.Name, g.Text, C.Pink)
		gearButtons[g.Id] = UiKit.Button(f, NumberFormat.Cells(g.Price), { Size = UDim2.new(1, -16, 0, 44), Position = UDim2.fromOffset(8, 116), BackgroundColor3 = Color3.fromRGB(190, 60, 130) }, function()
			Remotes.Send("BuyGear", g.Id)
		end)
	end
	UiKit.Label(content, { Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(0, 180), Text = "THOUGHT BUBBLES · placed on your Lobe pads (Lobe LV 2+)", TextColor3 = C.Cyan, TextXAlignment = Enum.TextXAlignment.Left })
	for i, b in BUBBLES do
		local f = card(content, (i - 1) * 148, 212, b.Icon, b.Kind .. " Bubble", b.Text, C.Cyan)
		UiKit.Button(f, NumberFormat.Cells(b.Price), { Size = UDim2.new(1, -16, 0, 44), Position = UDim2.fromOffset(8, 116), BackgroundColor3 = Color3.fromRGB(40, 150, 190) }, function()
			Remotes.Send("BuyBubble", b.Kind)
		end)
	end
	local function render(s)
		if not win.Visible then
			return
		end
		for _, g in GEAR do
			if not g.Consumable and (s.Gear or {})[g.Id] then
				gearButtons[g.Id].Text = "OWNED ✅"
				gearButtons[g.Id].BackgroundColor3 = Color3.fromRGB(50, 110, 60)
			end
		end
	end
	ClientState.Changed.Event:Connect(render)
	UiKit.OnOpen(win, function()
		render(ClientState.State)
	end)
	InputController.Register("H", function()
		UiKit.Toggle(win)
	end)
end

return MartUI
