local RS = game:GetService("ReplicatedStorage")
local UpgradeConfig = require(RS.UpgradeConfig)
local NumberFormat = require(RS.NumberFormat)
local Remotes = require(RS.Remotes)
local UiKit = require(script.Parent.UiKit)
local ClientState = require(script.Parent.ClientState)
local InputController = require(script.Parent.InputController)

local C = UiKit.Colors

local UpgradeUI = {}

local LOBE_UNLOCKS = { "", "2 Thought Bubble pads", "2nd floor: safe from grass", "Brain Fog slot 2", "Neon sign + goo waterfall" }

function UpgradeUI.Start()
	local win, content = UiKit.Window("Upgrades", "⬆️ UPGRADES · 50 WAYS TO ROT FASTER", Vector2.new(820, 470), C.Yellow)
	local cols = {}
	for i, g in UpgradeConfig.Groups do
		local col = UiKit.Frame(content, { Size = UDim2.fromOffset(150, 300), Position = UDim2.fromOffset((i - 1) * 158, 0), BackgroundColor3 = C.PanelLight, Stroke = C.Yellow })
		UiKit.Label(col, { Size = UDim2.new(1, -10, 0, 34), Position = UDim2.fromOffset(5, 6), Text = g.Icon .. " " .. string.upper(g.Id), TextColor3 = C.Yellow })
		local level = UiKit.Label(col, { Size = UDim2.new(1, -10, 0, 26), Position = UDim2.fromOffset(5, 42), Text = "Lv 0/10" })
		UiKit.Label(col, { Size = UDim2.new(1, -14, 0, 70), Position = UDim2.fromOffset(7, 74), Text = g.Effect, TextColor3 = C.Gray, TextWrapped = true })
		local pips = {}
		for k = 1, UpgradeConfig.MaxTier do
			pips[k] = UiKit.Frame(col, { Size = UDim2.fromOffset(11, 18), Position = UDim2.fromOffset(8 + (k - 1) * 13.5, 156), BackgroundColor3 = C.Panel, BackgroundTransparency = 0, Corner = 3 })
		end
		local buy = UiKit.Button(col, "BUY", { Size = UDim2.new(1, -16, 0, 48), Position = UDim2.fromOffset(8, 240), BackgroundColor3 = Color3.fromRGB(60, 140, 40) }, function()
			Remotes.Send("BuyUpgrade", g.Id)
		end)
		cols[g.Id] = { Level = level, Pips = pips, Buy = buy }
	end
	local lobeCard = UiKit.Frame(content, { Size = UDim2.new(1, 0, 0, 90), Position = UDim2.fromOffset(0, 312), BackgroundColor3 = C.PanelLight, Stroke = C.Pink })
	local lobeText = UiKit.Label(lobeCard, { Size = UDim2.new(1, -230, 1, -16), Position = UDim2.fromOffset(12, 8), Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true })
	local lobeBuy = UiKit.Button(lobeCard, "UPGRADE LOBE", { Size = UDim2.fromOffset(200, 60), Position = UDim2.new(1, -212, 0, 15), BackgroundColor3 = Color3.fromRGB(190, 60, 130) }, function()
		Remotes.Send("UpgradeLobe")
	end)

	local function render(s)
		if not win.Visible then
			return
		end
		for id, col in cols do
			local tier = (s.Upgrades or {})[id] or 0
			col.Level.Text = "Lv " .. tier .. "/10"
			for k, pip in col.Pips do
				pip.BackgroundColor3 = k <= tier and C.Goo or C.Panel
			end
			col.Buy.Text = tier >= 10 and "MAX" or ((s.UpgradeCosts or {})[id] or "BUY")
		end
		local lv = s.LobeLevel or 1
		if lv >= 5 then
			lobeText.Text = "🧠 YOUR LOBE IS LV 5 · MAX ROT ACHIEVED"
			lobeBuy.Text = "MAX"
		else
			lobeText.Text = "🧠 LOBE LV " .. lv .. " → " .. (lv + 1) .. " · " .. LOBE_UNLOCKS[lv + 1] .. " · podiums " .. (s.LobeUsed or 0) .. "/" .. (s.LobeCap or 8)
			lobeBuy.Text = s.LobeCost and NumberFormat.Cells(s.LobeCost) or "UPGRADE"
		end
	end
	ClientState.Changed.Event:Connect(render)
	UiKit.OnOpen(win, function()
		render(ClientState.State)
	end)
	InputController.Register("U", function()
		UiKit.Toggle(win)
	end)
end

return UpgradeUI
