local RS = game:GetService("ReplicatedStorage")
local UpgradeConfig = require(RS.UpgradeConfig)
local Remotes = require(RS.Remotes)
local UiKit = require(script.Parent.UiKit)
local ClientState = require(script.Parent.ClientState)
local InputController = require(script.Parent.InputController)

local C = UiKit.Colors

local BrainWashUI = {}

function BrainWashUI.Start()
	local win, content = UiKit.Window("BrainWash", "🧼 BRAIN WASH · REBIRTH", Vector2.new(720, 440), C.Cyan)
	local left = UiKit.Frame(content, { Size = UDim2.fromOffset(330, 360), BackgroundColor3 = C.PanelLight, Stroke = C.Cyan })
	local current = UiKit.Label(left, { Size = UDim2.new(1, -20, 0, 34), Position = UDim2.fromOffset(10, 10), Text = "WASH 0", TextColor3 = C.Cyan })
	local nextText = UiKit.Label(left, { Size = UDim2.new(1, -20, 0, 120), Position = UDim2.fromOffset(10, 52), Text = "", TextWrapped = true })
	UiKit.Label(left, { Size = UDim2.new(1, -20, 0, 54), Position = UDim2.fromOffset(10, 180), Text = "Resets 🧠, brainrots and upgrades. Keeps the Brainpedia, Lobe LV and perks.", TextColor3 = C.Gray, TextWrapped = true })
	local washButton = UiKit.Button(left, "BRAIN WASH", { Size = UDim2.new(1, -20, 0, 70), Position = UDim2.fromOffset(10, 278), BackgroundColor3 = Color3.fromRGB(40, 150, 190) }, function()
		Remotes.Send("BrainWash")
	end)

	local right = UiKit.Frame(content, { Size = UDim2.fromOffset(330, 360), Position = UDim2.fromOffset(346, 0), BackgroundColor3 = C.PanelLight, Stroke = C.White })
	local aura = UiKit.Label(right, { Size = UDim2.new(1, -20, 0, 34), Position = UDim2.fromOffset(10, 10), Text = "✨ AURA POINTS: 0" })
	local perkButtons = {}
	for i, perk in UpgradeConfig.Perks do
		local b = UiKit.Button(right, "", { Size = UDim2.new(1, -20, 0, 54), Position = UDim2.fromOffset(10, 50 + (i - 1) * 60), TextXAlignment = Enum.TextXAlignment.Left }, function()
			Remotes.Send("BuyPerk", perk.Id)
		end)
		perkButtons[perk.Id] = { Button = b, Perk = perk }
	end

	local function render(s)
		if not win.Visible then
			return
		end
		current.Text = "WASH " .. (s.Washes or 0) .. " · INCOME x" .. (s.WashMult or 1)
		if s.NextWash then
			nextText.Text = "NEXT: WASH " .. ((s.Washes or 0) + 1) .. "\nCost " .. s.NextWash.Cost .. " · Income x" .. s.NextWash.Mult .. "\nUnlocks: " .. s.NextWash.Unlock .. "\n+" .. ((s.Washes or 0) + 1) .. " Aura Points"
			washButton.Text = s.NextWash.Ready and "BRAIN WASH NOW" or ("NEED " .. s.NextWash.Cost)
			washButton.BackgroundColor3 = s.NextWash.Ready and Color3.fromRGB(40, 150, 190) or Color3.fromRGB(70, 60, 80)
		else
			nextText.Text = "FULLY WASHED. The Deep Subconscious is open."
			washButton.Text = "MAX WASH"
		end
		aura.Text = "✨ AURA POINTS: " .. (s.AuraPoints or 0)
		for id, pb in perkButtons do
			local owned = (s.Perks or {})[id]
			pb.Button.Text = (owned and "✅ " or "✨" .. pb.Perk.Cost .. " · ") .. pb.Perk.Name .. ": " .. pb.Perk.Text
			pb.Button.BackgroundColor3 = owned and Color3.fromRGB(50, 110, 60) or C.Panel
		end
	end
	ClientState.Changed.Event:Connect(render)
	UiKit.OnOpen(win, function()
		render(ClientState.State)
	end)
	InputController.Register("R", function()
		UiKit.Toggle(win)
	end)
end

return BrainWashUI
