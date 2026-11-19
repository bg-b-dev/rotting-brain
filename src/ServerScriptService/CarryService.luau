local RS = game:GetService("ReplicatedStorage")
local BrainrotModelKit = require(RS.BrainrotModelKit)
local BrainrotCatalog = require(RS.BrainrotCatalog)
local RarityConfig = require(RS.RarityConfig)
local DataService = require(script.Parent.DataService)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)
local LobeService = require(script.Parent.LobeService)

local CarryService = {}

function CarryService.Capacity(player: Player)
	local p = DataService.Get(player)
	return 1 + (p.Perks.ExtraCarry and 1 or 0)
end

function CarryService.IsFull(player: Player)
	return #DataService.Rt(player).Carrying >= CarryService.Capacity(player)
end

function CarryService.ApplySpeed(player: Player)
	local p, rt = DataService.Get(player), DataService.Rt(player)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not (p and humanoid) then
		return
	end
	local speed = 16 * (1 + 0.05 * p.Upgrades.Speed) * (p.Gear.SigmaSneakers and 1.4 or 1)
	if #rt.Carrying > 0 then
		speed *= math.min(0.95, 0.7 + 0.025 * p.Upgrades.Speed)
	end
	humanoid.WalkSpeed = rt.Stunned and 0 or speed
end

local function refreshVisuals(player: Player)
	local rt = DataService.Rt(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	for _, c in rt.Carrying do
		if c.Model then
			c.Model:Destroy()
			c.Model = nil
		end
	end
	if not root then
		return
	end
	for i, c in rt.Carrying do
		local m = BrainrotModelKit.Build(c.Entry, { scale = 0.55, tag = false })
		for _, p in m:GetDescendants() do
			if p:IsA("BasePart") then
				p.Anchored = false
				p.CanCollide = false
				p.Massless = true
			end
		end
		m:PivotTo(root.CFrame * CFrame.new(0, 2.6 + (i - 1) * 2.4, 0.4))
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = m.PrimaryPart
		weld.Parent = m.PrimaryPart
		m.Name = "Carried"
		m.Parent = character
		c.Model = m
	end
end

function CarryService.PickUp(player: Player, entry, from)
	local rt = DataService.Rt(player)
	table.insert(rt.Carrying, { Entry = entry, From = from })
	refreshVisuals(player)
	CarryService.ApplySpeed(player)
end

function CarryService.Drop(player: Player, reason: string?)
	local rt = DataService.Rt(player)
	if not rt or #rt.Carrying == 0 then
		return
	end
	for _, c in rt.Carrying do
		if c.Model then
			c.Model:Destroy()
		end
		if c.From and c.From.Lobe then
			local owner = c.From.Lobe
			if (owner.Owner and owner.Owner.UserId == c.From.OwnerUserId) or (owner.NpcName and not c.From.OwnerUserId) then
				LobeService.Place(owner, c.Entry)
			end
		end
	end
	rt.Carrying = {}
	CarryService.ApplySpeed(player)
	HudNotify.PopupOver(player, "-1000 AURA", Color3.fromRGB(255, 70, 70), true)
	HudNotify.Feed(player, "💥 You dropped your brainrot" .. (reason and (" (" .. reason .. ")") or "") .. "!")
	GameSignals.Emit("Dropped", player, reason)
end

local fullWarned = {}

local function tryDeliver(player: Player)
	local rt = DataService.Rt(player)
	local lobe = rt.Lobe
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not (lobe and root and #rt.Carrying > 0 and LobeService.Contains(lobe, root.Position)) then
		return
	end
	local kept = {}
	for _, c in rt.Carrying do
		local idx = LobeService.Place(lobe, c.Entry)
		if idx then
			if c.Model then
				c.Model:Destroy()
			end
			local def = BrainrotCatalog.Get(c.Entry.Id)
			HudNotify.Popup(nil, c.From and "STOLEN! +RIZZ" or "+100 AURA", RarityConfig.ByName[def.Rarity].Color, LobeService.PodiumCFrame(lobe, idx).Position + Vector3.new(0, 7, 0), true)
			GameSignals.Emit("Acquired", player, c.Entry, c.From and "steal" or "buy")
		else
			table.insert(kept, c)
		end
	end
	rt.Carrying = kept
	if #kept > 0 and (fullWarned[player] or 0) < os.clock() then
		fullWarned[player] = os.clock() + 5
		HudNotify.PopupOver(player, "LOBE FULL! UPGRADE IT", Color3.fromRGB(255, 200, 60), true)
	end
	CarryService.ApplySpeed(player)
end

function CarryService.Start()
	GameSignals.On("PlayerReady", function(player)
		local function onCharacter(character)
			local humanoid = character:WaitForChild("Humanoid", 5)
			if humanoid then
				humanoid.Died:Connect(function()
					CarryService.Drop(player, "fainted")
				end)
				task.wait(0.2)
				CarryService.ApplySpeed(player)
			end
		end
		player.CharacterAdded:Connect(onCharacter)
		if player.Character then
			task.spawn(onCharacter, player.Character)
		end
	end)
	GameSignals.On("PlayerLeaving", function(player)
		CarryService.Drop(player, "left")
		fullWarned[player] = nil
	end)
	DataService.AddStateField(function(_, s, _, rt)
		s.Carrying = {}
		for _, c in rt.Carrying do
			local def = BrainrotCatalog.Get(c.Entry.Id)
			table.insert(s.Carrying, { Name = def.Name, Rarity = def.Rarity, Mut = c.Entry.Mut, Stolen = c.From ~= nil })
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.2)
			for _, player in DataService.Ready() do
				tryDeliver(player)
			end
		end
	end)
end

return CarryService
