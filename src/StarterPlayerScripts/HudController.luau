local RS = game:GetService("ReplicatedStorage")
local NumberFormat = require(RS.NumberFormat)
local RarityConfig = require(RS.RarityConfig)
local Remotes = require(RS.Remotes)
local UiKit = require(script.Parent.UiKit)
local ClientState = require(script.Parent.ClientState)
local InputController = require(script.Parent.InputController)

local C = UiKit.Colors

local HudController = {}

local BUFF_ICONS = { ["Sigma Mindset"] = "🗿", ["Energy Drink"] = "⚡", ["Fully Rotted"] = "🤢", ["Mind Block"] = "🛡️" }

local ui = {}
local feedLines = {}

local function buildTop(root)
	local banner = UiKit.Frame(root, { Name = "FeatureBanner", Size = UDim2.fromOffset(820, 24), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 6), BackgroundColor3 = Color3.fromRGB(20, 6, 28), Stroke = C.Pink, Corner = 12 })
	UiKit.Label(banner, { Size = UDim2.new(1, -16, 1, -4), Position = UDim2.fromOffset(8, 2), TextColor3 = C.Yellow, Text = "60 BRAINROTS · 8 RARITIES · 8 MUTATIONS · MEME BLENDER · THOUGHT BUBBLES · STEAL · DEFENSE · REBIRTH" })

	local cells = UiKit.Frame(root, { Name = "Cells", Size = UDim2.fromOffset(380, 64), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 36), Stroke = C.Goo, Corner = 14 })
	ui.Cells = UiKit.Label(cells, { Size = UDim2.new(1, -16, 0, 38), Position = UDim2.fromOffset(8, 2), Text = "🧠 0", TextColor3 = C.White })
	ui.Cps = UiKit.Label(cells, { Size = UDim2.new(1, -16, 0, 20), Position = UDim2.fromOffset(8, 40), Text = "+🧠0/s", TextColor3 = C.Goo })

	local event = UiKit.Frame(root, { Name = "EventBanner", Size = UDim2.fromOffset(440, 34), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 106), Stroke = C.Cyan, Corner = 12 })
	ui.Event = event
	ui.EventText = UiKit.Label(event, { Size = UDim2.new(1, -16, 1, -6), Position = UDim2.fromOffset(8, 3), Text = "NEXT EVENT SOON", TextColor3 = C.Cyan })

	local rot = UiKit.Frame(root, { Name = "RotMeter", Size = UDim2.fromOffset(250, 62), Position = UDim2.fromOffset(12, 60), Stroke = C.Goo, Corner = 12 })
	ui.RotText = UiKit.Label(rot, { Size = UDim2.new(1, -16, 0, 28), Position = UDim2.fromOffset(8, 4), Text = "BRAIN ROT 0%", TextColor3 = C.Goo, TextXAlignment = Enum.TextXAlignment.Left })
	local bar = UiKit.Frame(rot, { Size = UDim2.new(1, -16, 0, 18), Position = UDim2.fromOffset(8, 36), BackgroundColor3 = Color3.fromRGB(15, 5, 20), BackgroundTransparency = 0, Corner = 9 })
	ui.RotFill = UiKit.Frame(bar, { Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.Goo, BackgroundTransparency = 0, Corner = 9 })

	local buffs = Instance.new("Frame")
	buffs.Name = "Buffs"
	buffs.BackgroundTransparency = 1
	buffs.Size = UDim2.fromOffset(240, 160)
	buffs.AnchorPoint = Vector2.new(1, 0)
	buffs.Position = UDim2.new(1, -12, 0, 60)
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 4)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Right
	list.Parent = buffs
	buffs.Parent = root
	ui.Buffs = buffs

	local feed = Instance.new("Frame")
	feed.Name = "Feed"
	feed.BackgroundTransparency = 1
	feed.Size = UDim2.fromOffset(440, 96)
	feed.Position = UDim2.fromOffset(12, 132)
	feed.Parent = root
	for i = 1, 3 do
		feedLines[i] = UiKit.Label(feed, { Size = UDim2.new(1, 0, 0, 28), Position = UDim2.fromOffset(0, (i - 1) * 32), Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 0, TextStrokeTransparency = 0.2 })
	end
end

local function buildBottom(root)
	local carry = UiKit.Frame(root, { Name = "CarryLine", Size = UDim2.fromOffset(620, 40), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -96), BackgroundColor3 = Color3.fromRGB(60, 10, 30), Stroke = C.Yellow, Visible = false })
	ui.Carry = carry
	ui.CarryText = UiKit.Label(carry, { Size = UDim2.new(1, -16, 1, -8), Position = UDim2.fromOffset(8, 4), TextColor3 = C.Yellow, Text = "" })

	local bar = Instance.new("Frame")
	bar.Name = "ActionBar"
	bar.BackgroundTransparency = 1
	bar.Size = UDim2.fromOffset(#InputController.Keys * 92, 78)
	bar.AnchorPoint = Vector2.new(0.5, 1)
	bar.Position = UDim2.new(0.5, 0, 1, -10)
	bar.Parent = root
	ui.Actions = {}
	for i, k in InputController.Keys do
		local b = UiKit.Button(bar, "", { Name = k.Key, Size = UDim2.fromOffset(84, 74), Position = UDim2.fromOffset((i - 1) * 92 + 4, 2), BackgroundColor3 = C.Panel, BackgroundTransparency = 0.1 }, function()
			InputController.Trigger(k.Key)
		end)
		local stroke = Instance.new("UIStroke")
		stroke.Color = C.Pink
		stroke.Thickness = 2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = b
		UiKit.Label(b, { Size = UDim2.new(1, 0, 0, 30), Text = k.Icon })
		UiKit.Label(b, { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 30), Text = k.Label, TextColor3 = C.White })
		local keyLabel = UiKit.Label(b, { Name = "Key", Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 48), Text = "[" .. k.Key .. "]", TextColor3 = C.Yellow })
		ui.Actions[k.Key] = keyLabel
	end

	local glow = Instance.new("Frame")
	glow.Name = "RotGlow"
	glow.BackgroundTransparency = 1
	glow.Size = UDim2.fromScale(1, 1)
	glow.Visible = false
	local gs = Instance.new("UIStroke")
	gs.Color = C.Goo
	gs.Thickness = 14
	gs.Transparency = 0.25
	gs.Parent = glow
	glow.Parent = root
	ui.RotGlow = glow
end

local function chip(text, color)
	local f = UiKit.Frame(ui.Buffs, { Size = UDim2.fromOffset(240, 30), Stroke = color, Corner = 15 })
	UiKit.Label(f, { Size = UDim2.new(1, -12, 1, -6), Position = UDim2.fromOffset(6, 3), Text = text, TextColor3 = color })
end

local function render(s)
	ui.Cells.Text = NumberFormat.Cells(s.Cells or 0)
	ui.Cps.Text = "+" .. NumberFormat.Cells(s.Cps or 0) .. "/s · 🧼 WASH " .. (s.Washes or 0) .. " (x" .. (s.WashMult or 1) .. ")"
	local rot = math.floor(s.Rot or 0)
	if (s.RotFrenzy or 0) > 0 then
		ui.RotText.Text = "FULLY ROTTED x3 " .. NumberFormat.Clock(s.RotFrenzy)
		ui.RotFill.Size = UDim2.fromScale(1, 1)
	else
		ui.RotText.Text = "BRAIN ROT " .. rot .. "%"
		ui.RotFill.Size = UDim2.fromScale(rot / 100, 1)
	end
	ui.RotGlow.Visible = (s.RotFrenzy or 0) > 0
	if s.Event then
		ui.EventText.Text = s.Event.Icon .. " " .. string.upper(s.Event.Name) .. " · " .. NumberFormat.Clock(s.Event.Left)
		ui.EventText.TextColor3 = C.Yellow
		ui.Event.UIStroke.Color = C.Yellow
	elseif s.Next then
		ui.EventText.Text = "NEXT: " .. s.Next.Name .. " " .. NumberFormat.Clock(s.Next.In)
		ui.EventText.TextColor3 = C.Cyan
		ui.Event.UIStroke.Color = C.Cyan
	end
	for _, child in ui.Buffs:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	if (s.MindBlockLeft or 0) > 0 then
		chip("🛡️ MIND BLOCK " .. NumberFormat.Clock(s.MindBlockLeft), C.Pink)
	end
	for _, b in s.Buffs or {} do
		chip((BUFF_ICONS[b.Name] or "✨") .. " " .. string.upper(b.Name) .. " " .. NumberFormat.Clock(b.Left), C.Yellow)
	end
	local carrying = s.Carrying or {}
	ui.Carry.Visible = #carrying > 0
	if #carrying > 0 then
		local names = {}
		for _, c in carrying do
			table.insert(names, c.Name .. (c.Mut and (" (" .. c.Mut .. ")") or ""))
		end
		ui.CarryText.Text = "CARRYING: " .. table.concat(names, " + ") .. " -> RUN BACK TO YOUR LOBE"
		ui.CarryText.TextColor3 = RarityConfig.ByName[carrying[1].Rarity].Color:Lerp(C.Yellow, 0.4)
	end
	ui.Actions.L.Text = (s.MindBlockCd or 0) > 0 and NumberFormat.Clock(s.MindBlockCd) or "[L]"
	ui.Actions.F.Text = (s.SlapCd or 0) > 0 and "..." or "[F]"
end

function HudController.Feed(text: string)
	table.insert(feedLines, 1, table.remove(feedLines))
	for i, line in feedLines do
		line.Position = UDim2.fromOffset(0, (i - 1) * 32)
		line.TextTransparency = (i - 1) * 0.25
	end
	feedLines[1].Text = text
end

function HudController.Start()
	local _, root = UiKit.Screen("RottingBrainHud", 1)
	buildTop(root)
	buildBottom(root)
	ClientState.Changed.Event:Connect(render)
	Remotes.Get("Feed").OnClientEvent:Connect(HudController.Feed)
	HudController.Feed("🧠 Welcome to the ROTTING BRAIN. Buy memes on the Synapse Belt [E]!")
end

return HudController
