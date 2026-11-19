local RS = game:GetService("ReplicatedStorage")
local BrainrotCatalog = require(RS.BrainrotCatalog)
local RarityConfig = require(RS.RarityConfig)
local MutationConfig = require(RS.MutationConfig)
local NumberFormat = require(RS.NumberFormat)
local WorldBuilder = require(script.Parent.WorldBuilder)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local LobeService = require(script.Parent.LobeService)
local CarryService = require(script.Parent.CarryService)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)

local ThoughtBubbleHatch = { Visuals = {} }

ThoughtBubbleHatch.Kinds = {
	Basic = { Price = 500, Seconds = 30, MinRarity = 1, Luck = 0.3, Wash = 0, Color = Color3.new(1, 1, 1), Neon = false },
	Gold = { Price = 5e4, Seconds = 120, MinRarity = 3, Luck = 1, Wash = 1, Color = Color3.fromRGB(255, 205, 60), Neon = true },
	Galaxy = { Price = 5e6, Seconds = 300, MinRarity = 5, Luck = 2, Wash = 3, Color = Color3.fromRGB(150, 90, 255), Neon = true },
}

local rng = Random.new()

function ThoughtBubbleHatch.Duration(p, kind)
	local k = ThoughtBubbleHatch.Kinds[kind]
	return math.floor(k.Seconds * (1 - 0.06 * p.Upgrades.Thoughts) * (p.Perks.FastBubbles and 0.8 or 1))
end

function ThoughtBubbleHatch.BuildBubble(kind, at: CFrame)
	local k = ThoughtBubbleHatch.Kinds[kind]
	local m = Instance.new("Model")
	m.Name = kind .. "ThoughtBubble"
	local mat = k.Neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
	local core = WorldBuilder.Part(m, { Name = "Cloud", Shape = Enum.PartType.Ball, Size = Vector3.one * 3.2, CFrame = at * CFrame.new(0, 3.4, 0), Color = k.Color, Material = mat, Transparency = 0.1, CanCollide = false })
	m.PrimaryPart = core
	for _, o in { Vector3.new(-1.4, -0.3, 0), Vector3.new(1.4, -0.2, 0) } do
		WorldBuilder.Part(m, { Name = "Cloud", Shape = Enum.PartType.Ball, Size = Vector3.one * 2.4, CFrame = at * CFrame.new(Vector3.new(0, 3.4, 0) + o), Color = k.Color, Material = mat, Transparency = 0.1, CanCollide = false })
	end
	WorldBuilder.Part(m, { Name = "Trail", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.9, CFrame = at * CFrame.new(0.4, 1.3, 0), Color = k.Color, Material = mat, CanCollide = false })
	WorldBuilder.Part(m, { Name = "Trail", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.5, CFrame = at * CFrame.new(0.7, 0.6, 0), Color = k.Color, Material = mat, CanCollide = false })
	local label = WorldBuilder.Billboard(core, "?", { Name = "Timer", Size = UDim2.fromScale(5, 2.4), Offset = Vector3.new(0, 3, 0), Color = Color3.fromRGB(255, 215, 70), MaxDistance = 80 })
	label.Font = Enum.Font.LuckiestGuy
	local prompt = WorldBuilder.Prompt(core, "Pop", kind .. " Thought Bubble", 0.3)
	prompt.Name = "PopPrompt"
	prompt.Enabled = false
	return m, label, prompt
end

function ThoughtBubbleHatch.Refresh(lobe)
	for _, v in ThoughtBubbleHatch.Visuals[lobe.Index] or {} do
		v.Model:Destroy()
	end
	ThoughtBubbleHatch.Visuals[lobe.Index] = {}
	local owner = lobe.Owner
	local p = owner and DataService.Get(owner)
	if not p then
		return
	end
	for key, bubble in p.Bubbles do
		local pad = WorldBuilder.Layout.BubblePads[tonumber(key)]
		local m, label, prompt = ThoughtBubbleHatch.BuildBubble(bubble.Kind, lobe.CF * CFrame.new(pad))
		m.Parent = lobe.Model
		prompt.Triggered:Connect(function(player)
			if player == owner then
				ThoughtBubbleHatch.Pop(player, key)
			end
		end)
		ThoughtBubbleHatch.Visuals[lobe.Index][key] = { Model = m, Label = label, Prompt = prompt, Bubble = bubble }
	end
end

function ThoughtBubbleHatch.Add(player: Player, kind: string)
	local p, lobe = DataService.Get(player), LobeService.LobeOf(player)
	local k = ThoughtBubbleHatch.Kinds[kind]
	if not (p and lobe and k) then
		return false
	end
	if p.Washes < k.Wash then
		HudNotify.PopupOver(player, "NEEDS BRAIN WASH " .. k.Wash, Color3.fromRGB(255, 90, 90))
		return false
	end
	local free
	for i = 1, LobeService.BubblePadCount(lobe) do
		if not p.Bubbles[tostring(i)] then
			free = i
			break
		end
	end
	if not free then
		HudNotify.PopupOver(player, lobe.Level < 2 and "LOBE LV 2 UNLOCKS PADS" or "ALL PADS BUSY", Color3.fromRGB(255, 200, 60), true)
		return false
	end
	if not Economy.TrySpend(player, k.Price) then
		return false
	end
	p.Bubbles[tostring(free)] = { Kind = kind, ReadyAt = os.time() + ThoughtBubbleHatch.Duration(p, kind) }
	ThoughtBubbleHatch.Refresh(lobe)
	HudNotify.Feed(player, "💭 A " .. kind .. " Thought Bubble is forming on your Lobe...")
	return true
end

function ThoughtBubbleHatch.Pop(player: Player, key: string)
	local p, lobe = DataService.Get(player), LobeService.LobeOf(player)
	local bubble = p and p.Bubbles[key]
	if not (bubble and lobe) or os.time() < bubble.ReadyAt then
		return
	end
	local k = ThoughtBubbleHatch.Kinds[bubble.Kind]
	p.Bubbles[key] = nil
	local luck = Economy.Luck(player) + k.Luck
	local rarity = RarityConfig.Roll(rng, luck, k.MinRarity)
	local def = BrainrotCatalog.PickFromRarity(rng, rarity.Name, false)
	local entry = { Id = def.Id, Mut = MutationConfig.Roll(rng, luck, false), Lv = 1 }
	local pos = (lobe.CF * CFrame.new(WorldBuilder.Layout.BubblePads[tonumber(key)])).Position
	ThoughtBubbleHatch.Refresh(lobe)
	local burst = WorldBuilder.Part(workspace, { Name = "BubblePop", Size = Vector3.one, Position = pos + Vector3.new(0, 4, 0), Transparency = 1, CanCollide = false, CanQuery = false })
	local e = WorldBuilder.Sparkles(burst, k.Color, 0, "Pop")
	e.Speed = NumberRange.new(10, 16)
	e:Emit(40)
	game:GetService("Debris"):AddItem(burst, 2)
	if not LobeService.Place(lobe, entry) then
		CarryService.PickUp(player, entry, nil)
	end
	DataService.Bump(player, "BubblesPopped", 1)
	GameSignals.Emit("Acquired", player, entry, "bubble")
	HudNotify.Popup(nil, "POP! " .. string.upper(def.Rarity), RarityConfig.ByName[def.Rarity].Color, pos + Vector3.new(0, 8, 0), true)
end

function ThoughtBubbleHatch.Start()
	GameSignals.On("LobeAssigned", function(_, lobe)
		ThoughtBubbleHatch.Refresh(lobe)
	end)
	GameSignals.On("LobeReleased", ThoughtBubbleHatch.Refresh)
	GameSignals.On("BrainWashed", function(player)
		local lobe = LobeService.LobeOf(player)
		if lobe then
			ThoughtBubbleHatch.Refresh(lobe)
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			for _, visuals in ThoughtBubbleHatch.Visuals do
				for _, v in visuals do
					local left = v.Bubble.ReadyAt - os.time()
					v.Prompt.Enabled = left <= 0
					v.Label.Text = left <= 0 and "READY! [E]" or ("? " .. NumberFormat.Clock(left))
				end
			end
		end
	end)
end

return ThoughtBubbleHatch
