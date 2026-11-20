local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local BrainrotCatalog = require(RS.BrainrotCatalog)
local BrainrotModelKit = require(RS.BrainrotModelKit)
local RarityConfig = require(RS.RarityConfig)
local MutationConfig = require(RS.MutationConfig)
local NumberFormat = require(RS.NumberFormat)
local Remotes = require(RS.Remotes)
local UiKit = require(script.Parent.UiKit)

local C = UiKit.Colors

local CatchCardUI = {}

local SOURCE_TITLES = { blend = "🌀 MEME BLENDER CATCH!", bubble = "💭 BUBBLE HATCHED!", steal = "🦹 STOLEN CATCH!" }

local queue = {}
local showing = false

local function show(root, data)
	showing = true
	local def = BrainrotCatalog.Get(data.Id)
	local rarity = RarityConfig.ByName[def.Rarity]
	local mut = data.Mut and MutationConfig.ByName[data.Mut]
	local card = UiKit.Frame(root, { Name = "CatchCard", Size = UDim2.fromOffset(420, 330), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, -10), BackgroundColor3 = Color3.fromRGB(40, 14, 54), BackgroundTransparency = 0.02, Stroke = rarity.Color, Corner = 18 })
	card.UIStroke.Thickness = 4
	UiKit.Label(card, { Size = UDim2.new(1, -20, 0, 44), Position = UDim2.fromOffset(10, 8), Text = SOURCE_TITLES[data.Source] or "NEW BRAINROT!", Font = Enum.Font.LuckiestGuy, TextColor3 = C.Yellow })
	local vp, model = UiKit.Viewport(card, data, { Size = UDim2.fromOffset(170, 150), Position = UDim2.fromOffset(16, 58), BackgroundColor3 = rarity.Color, BackgroundTransparency = 0.75 })
	Instance.new("UICorner", vp).CornerRadius = UDim.new(0, 12)
	UiKit.Label(card, { Size = UDim2.fromOffset(210, 52), Position = UDim2.fromOffset(196, 58), Text = def.Name, TextWrapped = true })
	UiKit.Label(card, { Size = UDim2.fromOffset(210, 28), Position = UDim2.fromOffset(196, 112), Text = string.upper(def.Rarity), TextColor3 = rarity.Color })
	UiKit.Label(card, { Size = UDim2.fromOffset(210, 26), Position = UDim2.fromOffset(196, 142), Text = mut and ("✨ " .. mut.Name .. " x" .. mut.Mult) or "No mutation", TextColor3 = mut and mut.Color or C.Gray })
	UiKit.Label(card, { Size = UDim2.fromOffset(210, 28), Position = UDim2.fromOffset(196, 172), Text = NumberFormat.Cells(BrainrotModelKit.Income(data)) .. "/s · Lv " .. (data.Lv or 1), TextColor3 = C.Goo })
	UiKit.Label(card, { Size = UDim2.new(1, -32, 0, 60), Position = UDim2.fromOffset(16, 216), Text = "\"" .. def.Caption .. "\"", TextWrapped = true, TextColor3 = C.Pink, Font = Enum.Font.FredokaOne })
	UiKit.Label(card, { Size = UDim2.new(1, -32, 0, 26), Position = UDim2.fromOffset(16, 290), Text = "BRAINPEDIA " .. data.Found .. "/60 · +100 AURA", TextColor3 = C.Gray })
	local scale = Instance.new("UIScale")
	scale.Scale = 0.2
	scale.Parent = card
	TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 0.8 }):Play()
	local spin = RunService.RenderStepped:Connect(function(dt)
		model:PivotTo(model:GetPivot() * CFrame.Angles(0, dt * 1.5, 0))
	end)
	task.wait(workspace:GetAttribute("HoldCatchCard") or 4.5)
	spin:Disconnect()
	TweenService:Create(scale, TweenInfo.new(0.25), { Scale = 0 }):Play()
	task.wait(0.3)
	card:Destroy()
	showing = false
end

function CatchCardUI.Start()
	local _, root = UiKit.Screen("CatchCard", 8)
	Remotes.Get("CatchCard").OnClientEvent:Connect(function(data)
		table.insert(queue, data)
		if showing then
			return
		end
		while #queue > 0 do
			show(root, table.remove(queue, 1))
		end
	end)
end

return CatchCardUI
