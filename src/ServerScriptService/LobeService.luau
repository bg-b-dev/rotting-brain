local RS = game:GetService("ReplicatedStorage")
local BrainrotModelKit = require(RS.BrainrotModelKit)
local BrainrotCatalog = require(RS.BrainrotCatalog)
local RarityConfig = require(RS.RarityConfig)
local NumberFormat = require(RS.NumberFormat)
local Remotes = require(RS.Remotes)
local WorldBuilder = require(script.Parent.WorldBuilder)
local DataService = require(script.Parent.DataService)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)

local Layout = WorldBuilder.Layout

local LobeService = { Lobes = {}, StealHandler = nil }

LobeService.TierCost = { 5e3, 1e5, 5e6, 5e8 }
local PLAYER_LOBE_ORDER = { 2, 6, 4, 8, 1, 5, 3, 7 }
local TIER_UNLOCK = { "", "2 Thought Bubble pads", "Second floor (safe from the Touch Grass Wave)", "Brain Fog slot 2", "Neon sign, gold trim, goo waterfall" }

local function setVisible(root: Instance, on: boolean)
	local items = root:GetDescendants()
	table.insert(items, root)
	for _, d in items do
		if d:IsA("BasePart") then
			if d:GetAttribute("BaseT") == nil then
				d:SetAttribute("BaseT", d.Transparency)
				d:SetAttribute("BaseC", d.CanCollide)
			end
			d.Transparency = on and d:GetAttribute("BaseT") or 1
			d.CanCollide = on and d:GetAttribute("BaseC") or false
		elseif d:IsA("SurfaceGui") or d:IsA("BillboardGui") or d:IsA("ParticleEmitter") then
			d.Enabled = on
		end
	end
end
LobeService.SetVisible = setVisible

function LobeService.Capacity(lobe)
	return Layout.PodiumTierCount[lobe.Level] or 8
end

function LobeService.BubblePadCount(lobe)
	if lobe.Level < 2 then
		return 0
	end
	local p = lobe.Owner and DataService.Get(lobe.Owner)
	local thoughts = p and p.Upgrades.Thoughts or 0
	return 2 + (thoughts >= 5 and 1 or 0) + (thoughts >= 10 and 1 or 0)
end

function LobeService.ApplyTier(lobe)
	local m = lobe.Model
	setVisible(m.Tier3, lobe.Level >= 3)
	setVisible(m.Tier5, lobe.Level >= 5)
	local cap = LobeService.Capacity(lobe)
	for _, podium in m.Podiums:GetChildren() do
		setVisible(podium, podium:GetAttribute("PodiumIndex") <= cap)
	end
	local pads = LobeService.BubblePadCount(lobe)
	for _, pad in m.BubblePads:GetChildren() do
		setVisible(pad, pad:GetAttribute("PadIndex") <= pads)
	end
	setVisible(m.CannonSlots.CannonSlot2, lobe.Level >= 4)
end

function LobeService.UpdateLabel(lobe)
	local text
	if lobe.Owner then
		text = "🧠 " .. string.upper(lobe.Owner.DisplayName) .. "'S LOBE · LV " .. lobe.Level
	elseif lobe.NpcName then
		text = "📱 " .. lobe.NpcName .. "'S LOBE · NPC"
	else
		text = "EMPTY LOBE " .. lobe.Index
	end
	lobe.Model.Sign.OwnerLabel.Text.Text = text
end

function LobeService.PodiumCFrame(lobe, idx: number)
	return lobe.CF * CFrame.new(Layout.Podiums[idx] + Vector3.new(0, 2.25, 0))
end

function LobeService.SetEntry(lobe, idx: number, entry)
	local key = tostring(idx)
	LobeService.ClearModel(lobe, key)
	lobe.Entries[key] = entry
	local model = BrainrotModelKit.Build(entry)
	model:PivotTo(LobeService.PodiumCFrame(lobe, idx))
	model:SetAttribute("PodiumIndex", idx)
	local prompt = WorldBuilder.Prompt(model.PrimaryPart, "Steal", BrainrotCatalog.Get(entry.Id).Name, 1.2)
	prompt.Name = "StealPrompt"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Triggered:Connect(function(player)
		if LobeService.StealHandler and player ~= lobe.Owner then
			LobeService.StealHandler(player, lobe, idx)
		end
	end)
	local folder = lobe.Model:FindFirstChild("Brainrots") or Instance.new("Folder")
	folder.Name = "Brainrots"
	folder.Parent = lobe.Model
	model.Parent = folder
	lobe.Models[key] = model
	local top = lobe.Model.Podiums["Podium" .. idx].Top
	top.Color = RarityConfig.ByName[BrainrotCatalog.Get(entry.Id).Rarity].Color
	top.Material = Enum.Material.Neon
end

function LobeService.ClearModel(lobe, key: string)
	if lobe.Models[key] then
		lobe.Models[key]:Destroy()
		lobe.Models[key] = nil
	end
	local podium = lobe.Model.Podiums:FindFirstChild("Podium" .. key)
	if podium then
		podium.Top.Color = WorldBuilder.Colors.Cream
		podium.Top.Material = Enum.Material.SmoothPlastic
	end
end

function LobeService.RemoveEntry(lobe, idx: number)
	local key = tostring(idx)
	local entry = lobe.Entries[key]
	lobe.Entries[key] = nil
	LobeService.ClearModel(lobe, key)
	return entry
end

function LobeService.FreeSlot(lobe)
	for i = 1, LobeService.Capacity(lobe) do
		if not lobe.Entries[tostring(i)] then
			return i
		end
	end
	return nil
end

function LobeService.Place(lobe, entry)
	local idx = LobeService.FreeSlot(lobe)
	if idx then
		LobeService.SetEntry(lobe, idx, entry)
	end
	return idx
end

function LobeService.LobeOf(player: Player)
	local rt = DataService.Rt(player)
	return rt and rt.Lobe
end

function LobeService.LocalPoint(lobe, pos: Vector3)
	return lobe.CF:PointToObjectSpace(pos)
end

function LobeService.Contains(lobe, pos: Vector3)
	local p = lobe.CF:PointToObjectSpace(pos)
	return math.abs(p.X) <= 21 and math.abs(p.Z) <= 16 and p.Y > -3 and p.Y < 32
end

function LobeService.LobeAt(pos: Vector3)
	for _, lobe in LobeService.Lobes do
		if LobeService.Contains(lobe, pos) then
			return lobe
		end
	end
	return nil
end

function LobeService.ClearAll(lobe)
	for key in lobe.Models do
		LobeService.ClearModel(lobe, key)
	end
	lobe.Entries = {}
end

local function assign(player: Player)
	local lobe
	for _, i in PLAYER_LOBE_ORDER do
		local l = LobeService.Lobes[i]
		if not l.Owner and not l.NpcName then
			lobe = l
			break
		end
	end
	if not lobe then
		for _, i in PLAYER_LOBE_ORDER do
			local l = LobeService.Lobes[i]
			if not l.Owner then
				lobe = l
				break
			end
		end
	end
	if not lobe then
		return
	end
	GameSignals.Emit("LobeClaiming", lobe)
	LobeService.ClearAll(lobe)
	local p = DataService.Get(player)
	lobe.Owner = player
	lobe.NpcName = nil
	lobe.Level = p.LobeLevel
	lobe.Entries = p.Podiums
	lobe.Model:SetAttribute("OwnerUserId", player.UserId)
	DataService.Rt(player).Lobe = lobe
	for key, entry in p.Podiums do
		LobeService.SetEntry(lobe, tonumber(key), entry)
	end
	LobeService.ApplyTier(lobe)
	LobeService.UpdateLabel(lobe)
	GameSignals.Emit("LobeAssigned", player, lobe)
	local function toLobe(character)
		local root = character:WaitForChild("HumanoidRootPart", 5)
		if root then
			task.wait()
			character:PivotTo(lobe.CF * CFrame.new(0, 5, -9))
		end
	end
	player.CharacterAdded:Connect(toLobe)
	if player.Character then
		task.spawn(toLobe, player.Character)
	end
end

local function release(player: Player)
	local lobe = LobeService.LobeOf(player)
	if not lobe then
		return
	end
	for key in lobe.Models do
		LobeService.ClearModel(lobe, key)
	end
	lobe.Entries = {}
	lobe.Owner = nil
	lobe.Level = 1
	lobe.Model:SetAttribute("OwnerUserId", nil)
	LobeService.ApplyTier(lobe)
	LobeService.UpdateLabel(lobe)
	GameSignals.Emit("LobeReleased", lobe)
end

function LobeService.UpgradeLobe(player: Player)
	local lobe = LobeService.LobeOf(player)
	local p = DataService.Get(player)
	if not lobe or lobe.Level >= 5 then
		return
	end
	if lobe.Level == 4 and p.Washes < 4 then
		HudNotify.PopupOver(player, "NEEDS BRAIN WASH 4", Color3.fromRGB(255, 90, 90))
		return
	end
	local Economy = require(script.Parent.BrainCellEconomy)
	if Economy.TrySpend(player, LobeService.TierCost[lobe.Level]) then
		lobe.Level += 1
		p.LobeLevel = lobe.Level
		LobeService.ApplyTier(lobe)
		LobeService.UpdateLabel(lobe)
		HudNotify.Popup(nil, "LOBE LV " .. lobe.Level .. "!", Color3.fromRGB(255, 158, 199), lobe.CF.Position + Vector3.new(0, 12, 0), true)
		HudNotify.Feed(player, "🧠 Lobe LV " .. lobe.Level .. ": " .. TIER_UNLOCK[lobe.Level])
		GameSignals.Emit("LobeUpgraded", player, lobe)
		DataService.Bump(player, "LobeUpgrades", 1)
	end
end

function LobeService.Start()
	local world = workspace:WaitForChild("BrainWorld")
	for i, cf in Layout.Lobes do
		local model = world:WaitForChild("Lobe" .. i)
		local lobe = { Index = i, CF = cf, Model = model, Owner = nil, NpcName = nil, Entries = {}, Models = {}, Level = 1 }
		LobeService.Lobes[i] = lobe
		local att = Instance.new("Attachment")
		att.Name = "UpgradePoint"
		att.Position = model.Platform.CFrame:PointToObjectSpace((cf * CFrame.new(-12, 3, -13.5)).Position)
		att.Parent = model.Platform
		local prompt = WorldBuilder.Prompt(att, "Upgrade Lobe", "", 0.4)
		prompt.Name = "UpgradePrompt"
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.Triggered:Connect(function(player)
			if lobe.Owner == player then
				LobeService.UpgradeLobe(player)
			end
		end)
		LobeService.ApplyTier(lobe)
		LobeService.UpdateLabel(lobe)
	end
	task.spawn(function()
		while true do
			task.wait(1)
			for _, lobe in LobeService.Lobes do
				local prompt = lobe.Model.Platform.UpgradePoint.UpgradePrompt
				prompt.Enabled = lobe.Owner ~= nil and lobe.Level < 5
				if lobe.Level < 5 then
					prompt.ObjectText = "LV " .. (lobe.Level + 1) .. " · " .. NumberFormat.Cells(LobeService.TierCost[lobe.Level])
				end
			end
		end
	end)
	GameSignals.On("PlayerReady", assign)
	GameSignals.On("PlayerLeaving", release)
	Remotes.OnRequest("UpgradeLobe", LobeService.UpgradeLobe)
	DataService.AddStateField(function(player, s)
		local lobe = LobeService.LobeOf(player)
		if lobe then
			s.LobeLevel = lobe.Level
			s.LobeIndex = lobe.Index
			s.LobeCost = LobeService.TierCost[lobe.Level]
			local n = 0
			for _ in lobe.Entries do
				n += 1
			end
			s.LobeUsed = n
			s.LobeCap = LobeService.Capacity(lobe)
		end
	end)
end

return LobeService
