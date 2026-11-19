local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local BrainrotModelKit = require(RS.BrainrotModelKit)
local BrainrotCatalog = require(RS.BrainrotCatalog)
local NumberFormat = require(RS.NumberFormat)
local WorldBuilder = require(script.Parent.WorldBuilder)
local DataService = require(script.Parent.DataService)
local LobeService = require(script.Parent.LobeService)
local Economy = require(script.Parent.BrainCellEconomy)
local HudNotify = require(script.Parent.HudNotify)

local ProductivityPixieRaid = { Pixies = {}, Raiding = false }

local SKIN = Color3.fromRGB(255, 220, 190)
local PIXIE_SHEET = {
	{ Name = "Body", Shape = "Ell", Size = Vector3.new(1.6, 2, 1.4), Pos = Vector3.new(0, 1.6, 0), Color = Color3.fromRGB(150, 205, 255) },
	{ Name = "Head", Shape = "Ball", Size = Vector3.one * 1.5, Pos = Vector3.new(0, 3.2, 0), Color = SKIN },
	{ Name = "Hair", Shape = "Ell", Size = Vector3.new(1.6, 0.7, 1.6), Pos = Vector3.new(0, 3.85, 0.15), Color = Color3.fromRGB(120, 70, 40) },
	{ Name = "GlassLeft", Size = Vector3.new(0.5, 0.4, 0.1), Pos = Vector3.new(-0.33, 3.3, -0.74), Color = Color3.fromRGB(20, 20, 30) },
	{ Name = "GlassRight", Size = Vector3.new(0.5, 0.4, 0.1), Pos = Vector3.new(0.33, 3.3, -0.74), Color = Color3.fromRGB(20, 20, 30) },
	{ Name = "Bridge", Size = Vector3.new(0.3, 0.08, 0.08), Pos = Vector3.new(0, 3.38, -0.76), Color = Color3.fromRGB(20, 20, 30) },
	{ Name = "WingLeft", Shape = "Ell", Size = Vector3.new(0.15, 2, 1.3), Pos = Vector3.new(-0.95, 2.3, 0.6), Rot = Vector3.new(0, 0.4, 0.5), Color = Color3.fromRGB(220, 250, 255), Neon = true, T = 0.45 },
	{ Name = "WingRight", Shape = "Ell", Size = Vector3.new(0.15, 2, 1.3), Pos = Vector3.new(0.95, 2.3, 0.6), Rot = Vector3.new(0, -0.4, -0.5), Color = Color3.fromRGB(220, 250, 255), Neon = true, T = 0.45 },
	{ Name = "Clipboard", Size = Vector3.new(1, 1.3, 0.1), Pos = Vector3.new(0.9, 1.7, -0.65), Color = Color3.fromRGB(150, 100, 60) },
	{ Name = "Worksheet", Size = Vector3.new(0.8, 1, 0.05), Pos = Vector3.new(0.9, 1.65, -0.72), Color = Color3.new(1, 1, 1) },
}

local function buildPixie()
	local m = Instance.new("Model")
	m.Name = "ProductivityPixie"
	local body
	for _, row in PIXIE_SHEET do
		local p = Instance.new("Part")
		p.Name = row.Name
		p.Size = row.Size
		p.CFrame = CFrame.new(row.Pos) * (row.Rot and CFrame.Angles(row.Rot.X, row.Rot.Y, row.Rot.Z) or CFrame.identity)
		p.Color = row.Color
		p.Material = row.Neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
		p.Transparency = row.T or 0
		p.CanCollide = false
		p.CanTouch = false
		p.Massless = true
		p.Anchored = true
		if row.Shape == "Ball" then
			p.Shape = Enum.PartType.Ball
		elseif row.Shape == "Ell" then
			Instance.new("SpecialMesh", p).MeshType = Enum.MeshType.Sphere
		end
		p.Parent = m
		if row.Name == "Body" then
			body = p
			m.PrimaryPart = p
		end
	end
	for _, p in m:GetChildren() do
		if p ~= body then
			local w = Instance.new("WeldConstraint")
			w.Part0 = body
			w.Part1 = p
			w.Parent = p
		end
	end
	WorldBuilder.Billboard(body, "📋 PRODUCTIVITY PIXIE", { Size = UDim2.fromScale(8, 1.2), Offset = Vector3.new(0, 3.4, 0), Color = Color3.fromRGB(255, 90, 90), MaxDistance = 90 })
	local trail = WorldBuilder.Sparkles(body, Color3.new(1, 1, 1), 6, "PaperTrail")
	trail.LightEmission = 0
	trail.Size = NumberSequence.new(0.4)
	m.Parent = workspace
	local set = BrainrotModelKit.MakeGlider(m)
	body:SetNetworkOwner(nil)
	return m, set
end

local function hivePos()
	return WorldBuilder.Layout.HQ + Vector3.new(0, 21, 0)
end

local function pickTarget()
	local pool = {}
	for _, lobe in LobeService.Lobes do
		if next(lobe.Entries) and (lobe.Owner or lobe.NpcName) then
			for _ = 1, lobe.Owner and 3 or 1 do
				table.insert(pool, lobe)
			end
		end
	end
	if #pool == 0 then
		return nil
	end
	local lobe = pool[math.random(1, #pool)]
	local keys = {}
	for k in lobe.Entries do
		table.insert(keys, tonumber(k))
	end
	return lobe, keys[math.random(1, #keys)]
end

function ProductivityPixieRaid.SpawnPixie()
	local lobe, idx = pickTarget()
	if not lobe then
		return
	end
	local model, set = buildPixie()
	local pixie = { Model = model, Set = set, Pos = hivePos(), Lobe = lobe, Idx = idx, Phase = "seek", Speed = 16, Bob = math.random() * 6 }
	set(CFrame.new(pixie.Pos))
	table.insert(ProductivityPixieRaid.Pixies, pixie)
	return pixie
end

local function remove(pixie)
	local i = table.find(ProductivityPixieRaid.Pixies, pixie)
	if i then
		table.remove(ProductivityPixieRaid.Pixies, i)
	end
	pixie.Model:Destroy()
end

local function poof(pos)
	local p = WorldBuilder.Part(workspace, { Name = "Poof", Size = Vector3.one, Position = pos, Transparency = 1, CanCollide = false, CanQuery = false })
	local e = WorldBuilder.Sparkles(p, Color3.fromRGB(255, 255, 255), 0, "PoofBurst")
	e.Speed = NumberRange.new(6, 10)
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 0) })
	e:Emit(30)
	game:GetService("Debris"):AddItem(p, 2)
end

function ProductivityPixieRaid.Defeat(pixie, by: Player?, how: string)
	if pixie.Loot then
		local lobe = pixie.Lobe
		if (lobe.Owner and lobe.Owner.UserId == pixie.OwnerUserId) or (lobe.NpcName and not pixie.OwnerUserId) then
			LobeService.Place(lobe, pixie.Loot)
		end
	end
	local pos = pixie.Model:GetPivot().Position
	poof(pos)
	HudNotify.Popup(nil, how == "fog" and "BRAIN FOGGED!" or "-1000 AURA", Color3.fromRGB(255, 80, 80), pos + Vector3.new(0, 4, 0), true)
	if by then
		local p = DataService.Get(by)
		local bounty = math.floor(math.max(250, Economy.Cps(by) * 12) * ((p and p.Gear.SlapperSupremo) and 2 or 1) * (how == "fog" and 0.5 or 1))
		Economy.Add(by, bounty)
		HudNotify.Popup(by, "+" .. NumberFormat.Cells(bounty) .. " BOUNTY", Color3.fromRGB(150, 255, 110), pos + Vector3.new(0, 7, 0), true)
		DataService.Bump(by, "PixiesStopped", 1)
	end
	remove(pixie)
end

function ProductivityPixieRaid.SlapNear(player: Player, pos: Vector3, reach: number)
	local hits = 0
	for i = #ProductivityPixieRaid.Pixies, 1, -1 do
		local pixie = ProductivityPixieRaid.Pixies[i]
		local d = pixie.Model:GetPivot().Position - pos
		if Vector3.new(d.X, 0, d.Z).Magnitude <= reach and math.abs(d.Y) < 14 then
			hits += 1
			ProductivityPixieRaid.Defeat(pixie, player, "slap")
		end
	end
	return hits
end

local function grab(pixie)
	local lobe = pixie.Lobe
	if (lobe.MindBlockUntil or 0) > os.clock() then
		HudNotify.Popup(nil, "BLOCKED!", Color3.fromRGB(255, 90, 200), pixie.Pos, true)
		pixie.Phase = "flee"
		return
	end
	local entry = LobeService.RemoveEntry(lobe, pixie.Idx)
	if not entry then
		pixie.Phase = "flee"
		return
	end
	pixie.Loot = entry
	pixie.OwnerUserId = lobe.Owner and lobe.Owner.UserId
	pixie.Phase = "flee"
	pixie.Speed = 9
	local loot = BrainrotModelKit.Build(entry, { scale = 0.5, tag = false, fx = false })
	loot:PivotTo(pixie.Model:GetPivot() * CFrame.new(0, -1.6, 0))
	for _, part in loot:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.Massless = true
		end
	end
	local w = Instance.new("WeldConstraint")
	w.Part0 = pixie.Model.PrimaryPart
	w.Part1 = loot.PrimaryPart
	w.Parent = loot.PrimaryPart
	loot.Parent = pixie.Model
	if lobe.Owner then
		HudNotify.Feed(lobe.Owner, "📋 A Productivity Pixie grabbed your " .. BrainrotCatalog.Get(entry.Id).Name .. "! Focus Slap it [F]!")
	end
end

local function step(dt)
	local t = os.clock()
	for i = #ProductivityPixieRaid.Pixies, 1, -1 do
		local pixie = ProductivityPixieRaid.Pixies[i]
		local goal
		if pixie.Phase == "seek" then
			goal = LobeService.PodiumCFrame(pixie.Lobe, pixie.Idx).Position + Vector3.new(0, 3, 0)
		else
			goal = hivePos()
		end
		local delta = goal - pixie.Pos
		if delta.Magnitude < 2 then
			if pixie.Phase == "seek" then
				grab(pixie)
			else
				if pixie.Loot and pixie.Lobe.Owner then
					HudNotify.Feed(pixie.Lobe.Owner, "📚 A pixie turned your " .. BrainrotCatalog.Get(pixie.Loot.Id).Name .. " into homework. -1000 AURA")
				end
				remove(pixie)
			end
		else
			local travel = delta.Unit * math.min(delta.Magnitude, pixie.Speed * dt)
			local cruise = pixie.Phase == "seek" and delta.Magnitude > 20 and 14 or 0
			pixie.Pos += travel + Vector3.new(0, (math.max(goal.Y + cruise, 6) - pixie.Pos.Y) * math.min(1, dt * 1.5), 0)
			local look = Vector3.new(delta.X, 0, delta.Z)
			local cf = CFrame.new(pixie.Pos + Vector3.new(0, math.sin(t * 6 + pixie.Bob) * 0.5, 0))
			pixie.Set(look.Magnitude > 0.1 and CFrame.lookAt(cf.Position, cf.Position + look) or cf)
		end
	end
end

function ProductivityPixieRaid.StartHomeworkRaid(duration: number)
	ProductivityPixieRaid.Raiding = true
	local hq = workspace.BrainWorld.ProductivityHQ
	local alarm = hq.AlarmLight.Alarm
	local rain = WorldBuilder.Part(workspace, { Name = "PaperRain", Size = Vector3.new(380, 1, 380), Position = Vector3.new(0, 95, 0), Transparency = 1, CanCollide = false, CanQuery = false })
	local e = WorldBuilder.Sparkles(rain, Color3.new(1, 1, 1), 80, "Worksheets")
	e.LightEmission = 0
	e.Size = NumberSequence.new(1.2)
	e.Lifetime = NumberRange.new(6, 8)
	e.Speed = NumberRange.new(10, 14)
	e.EmissionDirection = Enum.NormalId.Bottom
	e.SpreadAngle = Vector2.new(15, 15)
	e.Rotation = NumberRange.new(0, 360)
	e.RotSpeed = NumberRange.new(-120, 120)
	e.Texture = ""
	task.spawn(function()
		for _ = 1, 6 do
			ProductivityPixieRaid.SpawnPixie()
			task.wait(1.5)
		end
	end)
	local stop = os.clock() + duration
	while os.clock() < stop do
		alarm.Brightness = alarm.Brightness > 0 and 0 or 8
		task.wait(0.4)
	end
	alarm.Brightness = 0
	rain:Destroy()
	ProductivityPixieRaid.Raiding = false
end

function ProductivityPixieRaid.Start()
	RunService.Heartbeat:Connect(step)
	task.spawn(function()
		while true do
			task.wait(40)
			if #DataService.Ready() > 0 and #ProductivityPixieRaid.Pixies < 3 then
				ProductivityPixieRaid.SpawnPixie()
			end
		end
	end)
end

return ProductivityPixieRaid
