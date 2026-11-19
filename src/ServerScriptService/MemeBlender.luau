local RS = game:GetService("ReplicatedStorage")
local BrainrotCatalog = require(RS.BrainrotCatalog)
local BrainrotModelKit = require(RS.BrainrotModelKit)
local MutationConfig = require(RS.MutationConfig)
local Remotes = require(RS.Remotes)
local WorldBuilder = require(script.Parent.WorldBuilder)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local LobeService = require(script.Parent.LobeService)
local CarryService = require(script.Parent.CarryService)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)

local MemeBlender = { Jobs = {} }

local REACH = 45
local rng = Random.new()

function MemeBlender.Options(p)
	local groups = {}
	for key, entry in p.Podiums do
		groups[entry.Id] = groups[entry.Id] or { Id = entry.Id, Count = 0, MaxLv = 0, Keys = {} }
		local g = groups[entry.Id]
		g.Count += 1
		g.MaxLv = math.max(g.MaxLv, entry.Lv or 1)
		table.insert(g.Keys, key)
	end
	local list = {}
	for _, g in groups do
		if g.Count >= 3 then
			table.insert(list, g)
		end
	end
	table.sort(list, function(a, b)
		return a.Id > b.Id
	end)
	return list
end

local function nearBlender(player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	return root and (root.Position - WorldBuilder.Layout.Kitchen).Magnitude <= REACH
end

local function showInJar(entry)
	local kitchen = workspace.BrainWorld.MemeKitchen
	local old = kitchen:FindFirstChild("InJar")
	if old then
		old:Destroy()
	end
	if entry then
		local m = BrainrotModelKit.Build(entry, { scale = 0.6, tag = false, fx = false })
		m.Name = "InJar"
		m:PivotTo(CFrame.new(WorldBuilder.Layout.Kitchen + Vector3.new(0, 7, 0)))
		m.Parent = kitchen
	end
end

function MemeBlender.Blend(player: Player, id: number)
	local p = DataService.Get(player)
	local lobe = LobeService.LobeOf(player)
	if not (p and lobe) or MemeBlender.Jobs[player] then
		return
	end
	if not nearBlender(player) then
		HudNotify.PopupOver(player, "GO TO THE MEME KITCHEN", Color3.fromRGB(255, 200, 60))
		return
	end
	local group
	for _, g in MemeBlender.Options(p) do
		if g.Id == id then
			group = g
		end
	end
	if not group then
		return
	end
	table.sort(group.Keys, function(a, b)
		return (p.Podiums[a].Lv or 1) > (p.Podiums[b].Lv or 1)
	end)
	local bestMut, maxLv = nil, 0
	for i = 1, 3 do
		local entry = LobeService.RemoveEntry(lobe, tonumber(group.Keys[i]))
		maxLv = math.max(maxLv, entry.Lv or 1)
		if entry.Mut and (not bestMut or MutationConfig.Mult(entry.Mut) > MutationConfig.Mult(bestMut)) then
			bestMut = entry.Mut
		end
	end
	local duration = p.Washes >= 2 and 5 or 10
	local result = { Id = id, Lv = math.min(5, maxLv + 1), Mut = bestMut }
	local chance = p.Washes >= 2 and 0.4 or 0.25
	if maxLv >= 5 or rng:NextNumber() < chance then
		result.Mut = MutationConfig.Roll(rng, Economy.Luck(player) + 0.5, true)
	end
	local def = BrainrotCatalog.Get(id)
	MemeBlender.Jobs[player] = { Name = def.Name, EndsAt = os.clock() + duration, Duration = duration }
	showInJar(result)
	HudNotify.Feed(player, "🍝 Blending 3x " .. def.Name .. "...")
	task.delay(duration, function()
		MemeBlender.Jobs[player] = nil
		if not player.Parent then
			return
		end
		local home = LobeService.LobeOf(player)
		if not (home and LobeService.Place(home, result)) then
			CarryService.PickUp(player, result, nil)
		end
		DataService.Bump(player, "Blends", 1)
		GameSignals.Emit("Acquired", player, result, "blend")
		local text = "BLENDED! Lv " .. result.Lv .. (result.Mut and (" · " .. string.upper(result.Mut)) or "")
		HudNotify.Popup(nil, text, Color3.fromRGB(255, 158, 199), WorldBuilder.Layout.Kitchen + Vector3.new(0, 18, 0), true)
		HudNotify.Feed(player, "🍝 " .. text .. " " .. def.Name .. " went to your Lobe.")
		showInJar(nil)
	end)
end

function MemeBlender.Start()
	local kitchen = workspace.BrainWorld.MemeKitchen
	Remotes.OnRequest("Blend", MemeBlender.Blend)
	kitchen.Screen.Prompt.Triggered:Connect(function(player)
		Remotes.Fire("OpenUI", player, "Blender")
	end)
	DataService.AddStateField(function(player, s, p)
		s.BlendOptions = {}
		for _, g in MemeBlender.Options(p) do
			table.insert(s.BlendOptions, { Id = g.Id, Count = g.Count, MaxLv = g.MaxLv })
		end
		local job = MemeBlender.Jobs[player]
		s.BlendJob = job and { Name = job.Name, Left = math.max(0, job.EndsAt - os.clock()) } or nil
		s.NearBlender = nearBlender(player) and true or false
	end)
	local blade, status = kitchen.Blade, kitchen.Screen.Status.Text
	local bladeBase = blade.CFrame
	task.spawn(function()
		local angle = 0
		while true do
			local busy
			for _, job in MemeBlender.Jobs do
				busy = job
			end
			if busy then
				angle += 0.6
				blade.CFrame = bladeBase * CFrame.Angles(0, angle, 0)
				blade.Blade2.CFrame = blade.CFrame
				local jar = kitchen:FindFirstChild("InJar")
				if jar then
					jar:PivotTo(CFrame.new(WorldBuilder.Layout.Kitchen + Vector3.new(0, 7 + math.sin(angle) * 0.6, 0)) * CFrame.Angles(0, angle * 0.7, 0))
				end
				local pct = math.floor(100 * (1 - (busy.EndsAt - os.clock()) / busy.Duration))
				status.Text = "BLENDING " .. math.clamp(pct, 0, 100) .. "%"
			else
				status.Text = "MEME BLENDER [G]"
			end
			task.wait(0.05)
		end
	end)
end

return MemeBlender
