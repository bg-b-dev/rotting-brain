local Lighting = game:GetService("Lighting")

local WorldBuilder = {}

local C = {
	Brain = Color3.fromHex("C24F82"), Fold = Color3.fromHex("8A2A5A"), Cap = Color3.fromHex("FF9EC7"),
	CapFold = Color3.fromHex("D9578F"), Bone = Color3.fromHex("EDE4D3"), Goo = Color3.fromRGB(110, 255, 70),
	Nerve = Color3.fromRGB(0, 235, 255), Belt = Color3.fromRGB(48, 22, 74), Grass = Color3.fromHex("3FBF3A"),
	Magenta = Color3.fromRGB(120, 25, 80), Cream = Color3.fromRGB(255, 240, 220), Dark = Color3.fromRGB(25, 10, 30),
	Purple = Color3.fromRGB(110, 40, 190), Yellow = Color3.fromRGB(255, 210, 60), Cyan = Color3.fromRGB(60, 220, 255),
	Gold = Color3.fromRGB(255, 196, 40), Wood = Color3.fromRGB(120, 76, 44), Red = Color3.fromRGB(255, 40, 40),
}
WorldBuilder.Colors = C

local Layout = {
	MemeLobe = Vector3.new(0, 30, -135),
	BeltPath = {
		Vector3.new(0, 1.6, -100), Vector3.new(-30, 1.6, -100), Vector3.new(-30, 1.6, 25),
		Vector3.new(30, 1.6, 25), Vector3.new(30, 1.6, -100), Vector3.new(0, 1.6, -100),
	},
	Plaza = Vector3.new(0, 0, 60),
	Spawn = Vector3.new(0, 1.5, 52),
	Lobes = {},
	PodiumTierCount = { 8, 10, 14, 17, 20 },
	Podiums = {
		Vector3.new(-14, 1.5, -9), Vector3.new(-6, 1.5, -9), Vector3.new(2, 1.5, -9), Vector3.new(10, 1.5, -9),
		Vector3.new(-14, 1.5, -2), Vector3.new(-6, 1.5, -2), Vector3.new(2, 1.5, -2), Vector3.new(10, 1.5, -2),
		Vector3.new(-14, 1.5, 6), Vector3.new(-6, 1.5, 6),
		Vector3.new(-14, 14.5, 5), Vector3.new(-6, 14.5, 5), Vector3.new(2, 14.5, 5), Vector3.new(10, 14.5, 5),
		Vector3.new(-14, 14.5, 11), Vector3.new(-6, 14.5, 11), Vector3.new(2, 14.5, 11),
		Vector3.new(10, 14.5, 11), Vector3.new(2, 1.5, 6), Vector3.new(10, 1.5, 6),
	},
	BubblePads = { Vector3.new(-11, 1.5, -13.2), Vector3.new(-5.5, 1.5, -13.2), Vector3.new(5.5, 1.5, -13.2), Vector3.new(11, 1.5, -13.2) },
	CollectPad = Vector3.new(0, 1.5, -13.2),
	CannonSlots = { Vector3.new(-18, 1.5, -12.5), Vector3.new(-17.5, 14.5, 13) },
	SecondFloorY = 12,
	Mart = Vector3.new(-90, 0, 130),
	Kitchen = Vector3.new(0, 0, 130),
	Teaser = Vector3.new(85, 0, 125),
	HQ = Vector3.new(120, 0, -125),
	Subconscious = Vector3.new(-120, 0, -128),
	Wheel = Vector3.new(38, 0, 60),
	Board = Vector3.new(-38, 0, 60),
}
for i, p in ipairs({ { -115, -75 }, { -65, -75 }, { -115, -25 }, { -65, -25 }, { 65, -75 }, { 115, -75 }, { 65, -25 }, { 115, -25 } }) do
	local c = Vector3.new(p[1], 0, p[2])
	Layout.Lobes[i] = CFrame.lookAt(c, c + Vector3.new(p[1] < 0 and 1 or -1, 0, 0))
end
WorldBuilder.Layout = Layout

local KEEP_CLEAR = {
	{ -135, -95, -50, 0 }, { -135, 0, 50, 0 }, { -38, -175, 38, 30 }, { -36, 28, 36, 95 },
	{ -135, 100, 150, 160 }, { 90, -160, 160, -95 }, { -160, -165, -85, -95 },
}

local function isClear(x, z, pad)
	pad = pad or 4
	for _, r in KEEP_CLEAR do
		if x > r[1] - pad and x < r[3] + pad and z > r[2] - pad and z < r[4] + pad then
			return false
		end
	end
	return math.sqrt(x * x + z * z) < 188
end

function WorldBuilder.Part(parent, props)
	local p = Instance.new(props.Class or "Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props do
		if k ~= "Class" then
			p[k] = v
		end
	end
	p.Parent = parent
	return p
end
local Part = WorldBuilder.Part

function WorldBuilder.Label(part, text, props)
	props = props or {}
	local gui = Instance.new("SurfaceGui")
	gui.Face = props.Face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = props.PixelsPerStud or 20
	gui.LightInfluence = 0
	gui.Name = props.Name or "Label"
	local t = Instance.new("TextLabel")
	t.Name = "Text"
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = props.Background and 0 or 1
	t.BackgroundColor3 = props.Background or Color3.new()
	t.Text = text
	t.TextScaled = true
	t.Font = props.Font or Enum.Font.FredokaOne
	t.TextColor3 = props.Color or Color3.new(1, 1, 1)
	t.TextStrokeTransparency = props.Stroke or 0.3
	t.Parent = gui
	gui.Parent = part
	return t
end
local Label = WorldBuilder.Label

function WorldBuilder.Billboard(adornee, text, props)
	props = props or {}
	local bb = Instance.new("BillboardGui")
	bb.Name = props.Name or "Billboard"
	bb.Size = props.Size or UDim2.fromOffset(220, 60)
	bb.StudsOffset = props.Offset or Vector3.new(0, 4, 0)
	bb.AlwaysOnTop = props.AlwaysOnTop or false
	bb.MaxDistance = props.MaxDistance or 160
	bb.LightInfluence = 0
	local t = Instance.new("TextLabel")
	t.Name = "Text"
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextScaled = true
	t.Font = Enum.Font.FredokaOne
	t.TextColor3 = props.Color or Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0
	t.Parent = bb
	bb.Parent = adornee
	return t
end

function WorldBuilder.Prompt(part, action, objectText, holdTime)
	local pp = Instance.new("ProximityPrompt")
	pp.Name = "Prompt"
	pp.ActionText = action
	pp.ObjectText = objectText or ""
	pp.HoldDuration = holdTime or 0
	pp.MaxActivationDistance = 12
	pp.RequiresLineOfSight = false
	pp.Parent = part
	return pp
end

local function segment(parent, a, b, radius, color, material, name)
	local len = (b - a).Magnitude
	return Part(parent, {
		Name = name or "Segment", Shape = Enum.PartType.Cylinder, Size = Vector3.new(len + radius, radius * 2, radius * 2),
		CFrame = CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, math.rad(90), 0), Color = color,
		Material = material or Enum.Material.SmoothPlastic, CanCollide = false,
	})
end
WorldBuilder.Segment = segment

local function ball(parent, pos, size, color, material, name)
	return Part(parent, {
		Name = name or "Ball", Shape = Enum.PartType.Ball, Size = Vector3.one * size, Position = pos, Color = color,
		Material = material or Enum.Material.SmoothPlastic, CanCollide = false,
	})
end

local function glow(part, color, range, brightness)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range or 12
	l.Brightness = brightness or 2
	l.Parent = part
	return l
end

local function sparkles(part, color, rate, name)
	local e = Instance.new("ParticleEmitter")
	e.Name = name or "Sparkles"
	e.Color = ColorSequence.new(color)
	e.LightEmission = 1
	e.Rate = rate or 6
	e.Lifetime = NumberRange.new(1, 2)
	e.Speed = NumberRange.new(1, 3)
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
	e.SpreadAngle = Vector2.new(180, 180)
	e.Parent = part
	return e
end
WorldBuilder.Sparkles = sparkles

local function model(name, parent)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

local Builders = {}

function Builders.BrainFloor(spec, world)
	local m = model("BrainFloor")
	Part(m, { Name = "Floor", Size = Vector3.new(spec.Size, 4, spec.Size), Position = Vector3.new(0, -2, 0), Color = C.Brain })
	local rng = Random.new(307)
	local folds = model("FoldRidges", m)
	local made = 0
	while made < spec.Ridges do
		local p = Vector3.new(rng:NextNumber(-185, 185), 0, rng:NextNumber(-185, 185))
		if isClear(p.X, p.Z) then
			made += 1
			local heading = rng:NextNumber(0, math.pi * 2)
			for _ = 1, rng:NextInteger(4, 8) do
				heading += rng:NextNumber(-0.8, 0.8)
				local q = p + Vector3.new(math.cos(heading), 0, math.sin(heading)) * 7
				if not isClear(q.X, q.Z, 2) then
					break
				end
				local s = segment(folds, p, q, 1.6, C.Fold)
				s.CanCollide = true
				ball(folds, q, 3.2, C.Fold)
				p = q
			end
		end
	end
	local goo = model("GooPuddles", m)
	local n = 0
	while n < spec.Puddles do
		local x, z = rng:NextNumber(-180, 180), rng:NextNumber(-180, 180)
		if isClear(x, z, 1) then
			n += 1
			local d = rng:NextNumber(5, 12)
			Part(goo, { Name = "Goo", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, d, d * rng:NextNumber(0.6, 1)), CFrame = CFrame.new(x, 0.1, z) * CFrame.Angles(0, rng:NextNumber(0, 3), math.rad(90)), Color = C.Goo, Material = Enum.Material.Neon, CanCollide = false })
		end
	end
	local nerves = model("NeonNerves", m)
	for i = 1, spec.Nerves do
		local a = math.rad(i * 360 / spec.Nerves)
		local p = Vector3.new(math.cos(a) * 185, 0.2, math.sin(a) * 185)
		for _ = 1, 12 do
			local dir = (-p).Unit + Vector3.new(rng:NextNumber(-0.6, 0.6), 0, rng:NextNumber(-0.6, 0.6))
			local q = p + Vector3.new(dir.X, 0, dir.Z).Unit * 9
			if not isClear(q.X, q.Z, 0) then
				break
			end
			segment(nerves, p, q, 0.3, C.Nerve, Enum.Material.Neon, "Nerve")
			p = q
		end
	end
	m.Parent = world
end

function Builders.SkullWall(spec, world)
	local m = model("SkullWall")
	local seg = spec.Segments
	for i = 0, seg - 1 do
		local a = i / seg * math.pi * 2
		local pos = Vector3.new(math.cos(a), 0, math.sin(a)) * spec.Radius
		local w = 2 * math.pi * spec.Radius / seg + 1
		local cf = CFrame.lookAt(pos, Vector3.zero)
		Part(m, { Name = "Bone", Size = Vector3.new(w, spec.Height, 8), CFrame = cf + Vector3.new(0, spec.Height / 2, 0), Color = C.Bone })
		Part(m, { Name = "BoneTop", Size = Vector3.new(w, 30, 6), CFrame = (cf + Vector3.new(0, spec.Height + 10, 0)) * CFrame.new(0, 0, -6) * CFrame.Angles(math.rad(-35), 0, 0), Color = C.Bone })
	end
	for _, x in { -55, 55 } do
		Part(m, { Name = "EyeSocket", Shape = Enum.PartType.Cylinder, Size = Vector3.new(4, 34, 34), CFrame = CFrame.new(x, 52, -spec.Radius + 3) * CFrame.Angles(0, math.rad(90), 0), Color = C.Dark })
		local phone = Part(m, { Name = "PhoneGlow", Size = Vector3.new(12, 20, 0.5), CFrame = CFrame.new(x, 52, -spec.Radius + 5.5), Color = Color3.fromRGB(120, 200, 255), Material = Enum.Material.Neon })
		Label(phone, "3:07 AM", { Face = Enum.NormalId.Back, Color = Color3.fromRGB(20, 40, 90), Stroke = 1 })
		local l = Instance.new("SpotLight")
		l.Face = Enum.NormalId.Back
		l.Color = Color3.fromRGB(120, 200, 255)
		l.Range = 60
		l.Angle = 70
		l.Brightness = 4
		l.Parent = phone
	end
	m.Parent = world
end

function Builders.MemeLobe(spec, world)
	local m = model("MemeLobe")
	local center = Layout.MemeLobe
	local r = spec.Height / 2
	Part(m, { Name = "Brain", Shape = Enum.PartType.Ball, Size = Vector3.one * spec.Height, Position = center, Color = C.Cap })
	Part(m, { Name = "Split", Size = Vector3.new(1.2, spec.Height * 0.9, spec.Height * 0.95), Position = center + Vector3.new(0, 1, 0), Color = C.CapFold, CanCollide = false })
	local folds = model("Folds", m)
	for i = 1, spec.Folds do
		local lat = math.rad(-20 + i * 95 / spec.Folds)
		local phase = i * 1.7
		local prev
		for j = 0, 28 do
			local lon = math.rad(j * 360 / 28)
			local la = lat + math.sin(lon * 3 + phase) * 0.12
			local p = center + Vector3.new(math.cos(la) * math.cos(lon), math.sin(la), math.cos(la) * math.sin(lon)) * (r + 0.2)
			if prev then
				segment(folds, prev, p, 0.7, C.CapFold)
			end
			prev = p
		end
	end
	local neurons = model("Neurons", m)
	local rng = Random.new(60)
	for i = 1, spec.Neurons do
		local dir = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(0, 1), rng:NextNumber(-1, 1)).Unit
		local n = ball(neurons, center + dir * (r + 0.8), 2.2, i % 2 == 0 and C.Nerve or C.Goo, Enum.Material.Neon, "Neuron")
		glow(n, n.Color, 14, 3)
		sparkles(n, n.Color, 6, "NeuronSparks").Speed = NumberRange.new(4, 8)
	end
	for i = 1, 8 do
		local a = math.rad(i * 45)
		local p = center + Vector3.new(math.cos(a) * r * 0.75, -r * 0.6, math.sin(a) * r * 0.75)
		local drip = Part(m, { Name = "GooDrip", Size = Vector3.new(1.5, 8, 1.5), Position = p, Color = C.Goo, Material = Enum.Material.Neon, CanCollide = false })
		local drops = sparkles(drip, C.Goo, 4, "GooDrops")
		drops.Acceleration = Vector3.new(0, -25, 0)
		drops.EmissionDirection = Enum.NormalId.Bottom
	end
	local mouth = Part(m, { Name = "MemeMouth", Shape = Enum.PartType.Cylinder, Size = Vector3.new(2, 16, 16), CFrame = CFrame.new(0, 9, -104) * CFrame.Angles(0, math.rad(90), 0), Color = C.Dark, CanCollide = false })
	sparkles(mouth, C.Goo, 20)
	local sign = Part(m, { Name = "Sign", Size = Vector3.new(30, 6, 1), Position = center + Vector3.new(0, r + 7, 4), Color = C.Dark })
	Label(sign, "🧠 MEME LOBE", { Color = C.Cap, Background = C.Dark })
	Label(sign, "🧠 MEME LOBE", { Face = Enum.NormalId.Back, Color = C.Cap, Background = C.Dark })
	m.Parent = world
end

function Builders.SynapseBelt(spec, world)
	local m = model("SynapseBelt")
	local path = Layout.BeltPath
	for i = 1, #path - 1 do
		local a, b = path[i], path[i + 1]
		local mid, len = (a + b) / 2, (b - a).Magnitude
		local cf = CFrame.lookAt(mid, b)
		Part(m, { Name = "Belt", Size = Vector3.new(spec.Width, 1.4, len + spec.Width), CFrame = cf - Vector3.new(0, 0.9, 0), Color = C.Belt })
		Part(m, { Name = "NerveLine", Size = Vector3.new(1, 0.2, len + 1), CFrame = cf - Vector3.new(0, 0.1, 0), Color = C.Nerve, Material = Enum.Material.Neon, CanCollide = false })
		for _, side in { -1, 1 } do
			Part(m, { Name = "Rail", Size = Vector3.new(0.6, 1.2, len + spec.Width), CFrame = cf * CFrame.new(side * spec.Width / 2, 0.1, 0), Color = C.Nerve, Material = Enum.Material.Neon, CanCollide = false })
		end
	end
	m.Parent = world
end

function Builders.Lobe(spec, world, index)
	local cf = Layout.Lobes[index]
	local m = model("Lobe" .. index)
	m:SetAttribute("LobeIndex", index)
	local function at(v)
		return cf * CFrame.new(v)
	end
	Part(m, { Name = "Platform", Size = Vector3.new(spec.Width, 1.5, spec.Depth), CFrame = at(Vector3.new(0, 0.75, 0)), Color = C.Cap })
	for _, e in { { 0, -spec.Depth / 2, spec.Width + 1, 1 }, { 0, spec.Depth / 2, spec.Width + 1, 1 }, { -spec.Width / 2, 0, 1, spec.Depth }, { spec.Width / 2, 0, 1, spec.Depth } } do
		Part(m, { Name = "GooEdge", Size = Vector3.new(e[3], 0.6, e[4]), CFrame = at(Vector3.new(e[1], 1.6, e[2])), Color = C.Goo, Material = Enum.Material.Neon, CanCollide = false })
	end
	local tier3 = model("Tier3", m)
	Part(tier3, { Name = "SecondFloor", Size = Vector3.new(spec.Width, 1, 14), CFrame = at(Vector3.new(0, 14, 8)), Color = C.CapFold })
	for _, x in { -19, 19 } do
		for _, z in { 1.5, 14.5 } do
			Part(tier3, { Name = "Pillar", Shape = Enum.PartType.Cylinder, Size = Vector3.new(12.5, 1.5, 1.5), CFrame = at(Vector3.new(x, 7.75, z)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Magenta })
		end
	end
	local a, b = Vector3.new(17, 1.5, -13), Vector3.new(17, 14.5, 1.5)
	Part(tier3, { Name = "Ramp", Size = Vector3.new(6, 1, (b - a).Magnitude), CFrame = cf * CFrame.lookAt((a + b) / 2, b), Color = C.Magenta })
	Part(tier3, { Name = "Rail", Size = Vector3.new(spec.Width, 2, 0.4), CFrame = at(Vector3.new(0, 15.5, 1)), Color = C.Goo, Material = Enum.Material.Neon, CanCollide = false })
	local tier5 = model("Tier5", m)
	for _, e in { { 0, -spec.Depth / 2 - 0.6, spec.Width + 2, 0.6 }, { -spec.Width / 2 - 0.6, 0, 0.6, spec.Depth + 2 }, { spec.Width / 2 + 0.6, 0, 0.6, spec.Depth + 2 } } do
		Part(tier5, { Name = "GoldTrim", Size = Vector3.new(e[3], 1.8, e[4]), CFrame = at(Vector3.new(e[1], 0.9, e[2])), Color = C.Gold, Material = Enum.Material.Neon })
	end
	local fall = Part(tier5, { Name = "GooWaterfall", Size = Vector3.new(10, 13, 0.6), CFrame = at(Vector3.new(-8, 8, 15.4)), Color = C.Goo, Material = Enum.Material.Neon, CanCollide = false, Transparency = 0.2 })
	sparkles(fall, C.Goo, 15)
	local neon = Part(tier5, { Name = "NeonSign", Size = Vector3.new(16, 3, 0.4), CFrame = at(Vector3.new(0, 27.5, 15.2)), Color = C.Dark })
	Label(neon, "★ MAX ROT ★", { Color = C.Goo })
	local podiums = model("Podiums", m)
	for i, v in Layout.Podiums do
		local p = Part(podiums, { Name = "Podium" .. i, Shape = Enum.PartType.Cylinder, Size = Vector3.new(2, 5, 5), CFrame = at(v + Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Magenta })
		p:SetAttribute("PodiumIndex", i)
		Part(p, { Name = "Top", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 4.6, 4.6), CFrame = at(v + Vector3.new(0, 2.1, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Cream })
	end
	local pads = model("BubblePads", m)
	for i, v in Layout.BubblePads do
		local p = Part(pads, { Name = "BubblePad" .. i, Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 4.5, 4.5), CFrame = at(v + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.new(1, 1, 1), Material = Enum.Material.Neon, Transparency = 0.4 })
		p:SetAttribute("PadIndex", i)
	end
	local collect = Part(m, { Name = "CollectPad", Size = Vector3.new(4, 0.4, 3), CFrame = at(Layout.CollectPad + Vector3.new(0, 0.2, 0)), Color = C.Goo, Material = Enum.Material.Neon, CanCollide = false })
	WorldBuilder.Billboard(collect, "COLLECT 🧠0", { Name = "Bank", Offset = Vector3.new(0, 3, 0), Size = UDim2.fromScale(7, 1.6), MaxDistance = 80, Color = C.Goo })
	local slots = model("CannonSlots", m)
	for i, v in Layout.CannonSlots do
		local s = Part(slots, { Name = "CannonSlot" .. i, Size = Vector3.new(3, 0.3, 3), CFrame = at(v + Vector3.new(0, 0.15, 0)), Color = C.Dark })
		s:SetAttribute("SlotIndex", i)
	end
	for _, x in { -10, 10 } do
		Part(m, { Name = "SignPost", Size = Vector3.new(1, 25, 1), CFrame = at(Vector3.new(x, 13, 15.5)), Color = C.Magenta })
	end
	local sign = Part(m, { Name = "Sign", Size = Vector3.new(22, 5, 0.6), CFrame = at(Vector3.new(0, 23, 15.2)), Color = C.Dark })
	Label(sign, "EMPTY LOBE " .. index, { Name = "OwnerLabel", Color = C.Cap, Background = C.Dark })
	local field = Part(m, { Name = "MindBlockField", Size = Vector3.new(spec.Width + 2, 30, spec.Depth + 2), CFrame = at(Vector3.new(0, 15, 0)), Color = Color3.fromRGB(255, 90, 200), Material = Enum.Material.ForceField, Transparency = 1, CanCollide = false, CanQuery = false, CanTouch = false })
	field:SetAttribute("Active", false)
	m.Parent = world
end

function Builders.BrainStemPlaza(spec, world)
	local m = model("BrainStemPlaza")
	local c = Layout.Plaza
	Part(m, { Name = "Plaza", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1, spec.Radius * 2, spec.Radius * 2), CFrame = CFrame.new(c + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.CapFold })
	Part(m, { Name = "PlazaRing", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.1, spec.Radius * 2 + 2, spec.Radius * 2 + 2), CFrame = CFrame.new(c + Vector3.new(0, 0.45, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Goo, Material = Enum.Material.Neon })
	local fountain = model("GooFountain", m)
	local f = c + Vector3.new(0, 0, 12)
	Part(fountain, { Name = "Basin", Shape = Enum.PartType.Cylinder, Size = Vector3.new(2.5, 14, 14), CFrame = CFrame.new(f + Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Bone })
	Part(fountain, { Name = "Goo", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 12, 12), CFrame = CFrame.new(f + Vector3.new(0, 3.3, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Goo, Material = Enum.Material.Neon })
	Part(fountain, { Name = "Stem", Shape = Enum.PartType.Cylinder, Size = Vector3.new(7, 2, 2), CFrame = CFrame.new(f + Vector3.new(0, 6, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Bone })
	local top = ball(fountain, f + Vector3.new(0, 10, 0), 5, C.Cap, nil, "MiniBrain")
	local spray = sparkles(top, C.Goo, 40, "GooSpray")
	spray.Speed = NumberRange.new(8, 12)
	spray.Acceleration = Vector3.new(0, -25, 0)
	spray.SpreadAngle = Vector2.new(30, 30)
	spray.EmissionDirection = Enum.NormalId.Top
	local confetti = sparkles(top, C.Cap, 14, "Confetti")
	confetti.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.Cap), ColorSequenceKeypoint.new(0.5, C.Yellow), ColorSequenceKeypoint.new(1, C.Cyan) })
	confetti.Speed = NumberRange.new(16, 22)
	confetti.Acceleration = Vector3.new(0, -9, 0)
	confetti.Lifetime = NumberRange.new(3, 4)
	confetti.Size = NumberSequence.new(0.6)
	confetti.Rotation = NumberRange.new(0, 360)
	confetti.SpreadAngle = Vector2.new(50, 50)
	confetti.EmissionDirection = Enum.NormalId.Top
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PlazaSpawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = Layout.Spawn
	spawn.Color = C.Goo
	spawn.Material = Enum.Material.Neon
	spawn.Transparency = 0.5
	spawn.Duration = 0
	spawn.Parent = m
	m.Parent = world
end

function Builders.NeonSign(spec, world)
	local m = model("NeonSign")
	for _, x in { -spec.Width / 2 + 2, spec.Width / 2 - 2 } do
		Part(m, { Name = "Post", Size = Vector3.new(2, 34, 2), Position = Vector3.new(x, 17, 33), Color = C.Dark })
	end
	local board = Part(m, { Name = "Board", Size = Vector3.new(spec.Width, 11, 1), Position = Vector3.new(0, 39, 33), Color = C.Dark })
	Part(m, { Name = "Frame", Size = Vector3.new(spec.Width + 1.5, 12.5, 0.8), Position = Vector3.new(0, 39, 33), Color = C.Goo, Material = Enum.Material.Neon })
	for _, face in { Enum.NormalId.Front, Enum.NormalId.Back } do
		local t = Label(board, "ROTTING BRAIN", { Face = face, Color = C.Cap, Font = Enum.Font.LuckiestGuy, Stroke = 0, Name = "Sign" .. face.Name })
		local stroke = Instance.new("UIStroke")
		stroke.Color = C.Goo
		stroke.Thickness = 4
		stroke.Parent = t
	end
	glow(board, C.Cap, 40, 3)
	m.Parent = world
end

function Builders.MostRottedBoard(spec, world)
	local m = model("MostRottedBoard")
	local c = Layout.Board
	local cf = CFrame.lookAt(c, c + Vector3.new(1, 0, 0))
	for _, x in { -spec.Width / 2, spec.Width / 2 } do
		Part(m, { Name = "Post", Size = Vector3.new(1.2, spec.Height + 4, 1.2), CFrame = cf * CFrame.new(x, (spec.Height + 4) / 2, 0.8), Color = C.Dark })
	end
	Part(m, { Name = "Edge", Size = Vector3.new(spec.Width + 1, spec.Height + 1, 0.6), CFrame = cf * CFrame.new(0, spec.Height / 2 + 4, 0.6), Color = C.Goo, Material = Enum.Material.Neon })
	local screen = Part(m, { Name = "Screen", Size = Vector3.new(spec.Width, spec.Height, 0.6), CFrame = cf * CFrame.new(0, spec.Height / 2 + 4, 0), Color = C.Dark })
	screen:SetAttribute("Board", true)
	m.Parent = world
end

function Builders.BrainWheel(spec, world)
	local m = model("BrainWheel")
	local c = Layout.Wheel
	local cf = CFrame.lookAt(c, c + Vector3.new(-1, 0, 0))
	Part(m, { Name = "Stand", Size = Vector3.new(4, 9, 3), CFrame = cf * CFrame.new(0, 4.5, 1), Color = C.Dark })
	local hub = Part(m, { Name = "Hub", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.4, spec.Width, spec.Width), CFrame = cf * CFrame.new(0, spec.Width / 2 + 3, 0) * CFrame.Angles(0, math.rad(90), 0), Color = Color3.new(1, 1, 1) })
	local slices = model("Slices", m)
	local colors = { C.Cap, C.Goo, C.Cyan, C.Yellow, C.Cap, C.Goo, C.Cyan, C.Yellow }
	for i = 1, 8 do
		local a = math.rad((i - 0.5) * 45)
		local s = Part(slices, { Name = "Slice" .. i, Size = Vector3.new(0.4, spec.Width * 0.42, spec.Width * 0.3), CFrame = hub.CFrame * CFrame.Angles(a, 0, 0) * CFrame.new(-0.6, spec.Width * 0.22, 0), Color = colors[i], Material = Enum.Material.Neon, CanCollide = false })
		s:SetAttribute("Slice", i)
	end
	Part(m, { Name = "Pointer", Class = "WedgePart", Size = Vector3.new(1, 2, 2), CFrame = cf * CFrame.new(0, spec.Width + 3.8, -1) * CFrame.Angles(math.rad(180), 0, 0), Color = C.Red })
	local sign = Part(m, { Name = "Sign", Size = Vector3.new(10, 2.4, 0.4), CFrame = cf * CFrame.new(0, 1.8, -1.6), Color = C.Dark })
	Label(sign, "BRAIN WHEEL [E]", { Color = C.Yellow })
	WorldBuilder.Prompt(sign, "Spin", "Brain Wheel")
	m.Parent = world
end

function Builders.DopamineMart(spec, world)
	local m = model("DopamineMart")
	for i, k in spec.Kiosks do
		local c = Layout.Mart + Vector3.new((i - 2) * 22, 0, 0)
		local km = model(k.Name, m)
		local counter = Part(km, { Name = "Counter", Size = Vector3.new(12, 4, 4), Position = c + Vector3.new(0, 2, -3), Color = k.Color })
		for _, x in { -5.5, 5.5 } do
			Part(km, { Name = "Pole", Size = Vector3.new(1, spec.Height, 1), Position = c + Vector3.new(x, spec.Height / 2, 2), Color = C.Cream })
		end
		Part(km, { Name = "Roof", Size = Vector3.new(14, 1.2, 9), Position = c + Vector3.new(0, spec.Height, -1), Color = k.Color })
		local sign = Part(km, { Name = "Sign", Size = Vector3.new(12, 3, 0.5), Position = c + Vector3.new(0, spec.Height + 2, -4.5), Color = C.Dark, Material = Enum.Material.SmoothPlastic })
		Label(sign, k.Title, { Face = Enum.NormalId.Back, Color = k.Color })
		glow(sign, k.Color, 16, 2)
		WorldBuilder.Prompt(counter, "Open", k.Title)
		counter:SetAttribute("Kiosk", k.Name)
	end
	local title = Part(m, { Name = "Title", Size = Vector3.new(40, 5, 0.5), Position = Layout.Mart + Vector3.new(0, spec.Height + 7, -4.5), Color = C.Dark })
	Label(title, "💊 DOPAMINE MART [H]", { Face = Enum.NormalId.Back, Color = C.Yellow })
	m.Parent = world
end

function Builders.MemeBlender(spec, world)
	local m = model("MemeKitchen")
	local c = Layout.Kitchen
	Part(m, { Name = "Floor", Size = Vector3.new(36, 0.6, 28), Position = c + Vector3.new(0, 0.3, 0), Color = C.Cream })
	Part(m, { Name = "Base", Shape = Enum.PartType.Cylinder, Size = Vector3.new(4, 10, 10), CFrame = CFrame.new(c + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Magenta })
	local jar = Part(m, { Name = "Jar", Shape = Enum.PartType.Cylinder, Size = Vector3.new(spec.Height - 4, 8, 8), CFrame = CFrame.new(c + Vector3.new(0, spec.Height / 2 + 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(200, 240, 255), Material = Enum.Material.Glass, Transparency = 0.6, CanCollide = false })
	jar:SetAttribute("Blender", true)
	local blade = Part(m, { Name = "Blade", Size = Vector3.new(6, 0.3, 0.8), Position = c + Vector3.new(0, 5.5, 0), Color = Color3.fromRGB(200, 200, 210), Material = Enum.Material.Metal, CanCollide = false })
	Part(blade, { Name = "Blade2", Size = Vector3.new(0.8, 0.3, 6), Position = blade.Position, Color = blade.Color, Material = Enum.Material.Metal, CanCollide = false })
	Part(m, { Name = "Lid", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1, 8.6, 8.6), CFrame = CFrame.new(c + Vector3.new(0, spec.Height + 1, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Magenta })
	for i = 1, 3 do
		local s = Part(m, { Name = "Slot" .. i, Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 3.5, 3.5), CFrame = CFrame.new(c + Vector3.new((i - 2) * 5, 0.8, -8)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Goo, Material = Enum.Material.Neon })
		s:SetAttribute("Slot", i)
	end
	local screen = Part(m, { Name = "Screen", Size = Vector3.new(10, 4, 0.4), Position = c + Vector3.new(0, 4, -5.5), Color = C.Dark })
	Label(screen, "MEME BLENDER [G]", { Name = "Status", Face = Enum.NormalId.Front, Color = C.Goo })
	WorldBuilder.Prompt(screen, "Blend", "Meme Blender")
	Part(m, { Name = "OutputPad", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 5, 5), CFrame = CFrame.new(c + Vector3.new(10, 0.8, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Cap, Material = Enum.Material.Neon })
	local sign = Part(m, { Name = "Sign", Size = Vector3.new(26, 4, 0.5), Position = c + Vector3.new(0, spec.Height + 5, 4), Color = C.Dark })
	Label(sign, "🍝 MEME KITCHEN", { Color = C.Cap })
	Label(sign, "🍝 MEME KITCHEN", { Face = Enum.NormalId.Back, Color = C.Cap })
	m.Parent = world
end

function Builders.BrainTeaserCorner(spec, world)
	local m = model("BrainTeaserCorner")
	local c = Layout.Teaser
	local wall = Part(m, { Name = "QuizWall", Size = Vector3.new(18, 12, 1), Position = c + Vector3.new(-18, 6, 8), Color = C.Purple })
	Label(wall, "❓ MEME QUIZ\nPick the right brainrot!", { Face = Enum.NormalId.Front, Color = C.Yellow })
	WorldBuilder.Prompt(wall, "Play", "Meme Quiz")
	local track = model("GrassDodge", m)
	local start = c + Vector3.new(0, 0, -12)
	Part(track, { Name = "Track", Size = Vector3.new(spec.TrackLength, 0.6, 8), Position = start + Vector3.new(spec.TrackLength / 2, 0.3, 0), Color = C.Bone })
	local startPad = Part(track, { Name = "StartPad", Size = Vector3.new(4, 0.8, 8), Position = start + Vector3.new(0, 0.4, 0), Color = C.Cyan, Material = Enum.Material.Neon })
	startPad:SetAttribute("GrassDodge", "Start")
	local finish = Part(track, { Name = "FinishPad", Size = Vector3.new(4, 0.8, 8), Position = start + Vector3.new(spec.TrackLength, 0.4, 0), Color = C.Gold, Material = Enum.Material.Neon })
	finish:SetAttribute("GrassDodge", "Finish")
	for i = 1, spec.Blades do
		local b = Part(track, { Name = "GrassBlade", Size = Vector3.new(1, 5, 8), Position = start + Vector3.new(i * spec.TrackLength / (spec.Blades + 1), 3, 0), Color = C.Grass, Material = Enum.Material.Grass, CanCollide = false })
		b:SetAttribute("Phase", i * 1.3)
	end
	local sign = Part(m, { Name = "Sign", Size = Vector3.new(24, 4, 0.5), Position = c + Vector3.new(0, 15, 8), Color = C.Dark })
	Label(sign, "🧩 BRAIN TEASER CORNER", { Color = C.Cyan })
	Label(sign, "🧩 BRAIN TEASER CORNER", { Face = Enum.NormalId.Back, Color = C.Cyan })
	local gsign = Part(track, { Name = "DodgeSign", Size = Vector3.new(12, 3, 0.4), Position = start + Vector3.new(0, 5, -4.5), Color = C.Dark })
	Label(gsign, "🌱 GRASS DODGE", { Face = Enum.NormalId.Back, Color = C.Grass })
	m.Parent = world
end

function Builders.ProductivityHQ(spec, world)
	local m = model("ProductivityHQ")
	local c = Layout.HQ
	Part(m, { Name = "DeskTop", Size = Vector3.new(40, 2, 24), Position = c + Vector3.new(0, 14, 0), Color = C.Wood })
	for _, x in { -18, 18 } do
		for _, z in { -10, 10 } do
			Part(m, { Name = "DeskLeg", Size = Vector3.new(2, 13, 2), Position = c + Vector3.new(x, 6.5, z), Color = C.Wood })
		end
	end
	local rng = Random.new(5)
	for i = 1, 6 do
		local sheet = Part(m, { Name = "Homework", Size = Vector3.new(6, 0.2, 8), CFrame = CFrame.new(c + Vector3.new(rng:NextNumber(-15, 15), 15.2, rng:NextNumber(-8, 8))) * CFrame.Angles(0, rng:NextNumber(0, 3), 0), Color = Color3.new(1, 1, 1) })
		Label(sheet, i % 2 == 0 and "HOMEWORK\n2+2=?" or "DUE\nTOMORROW", { Face = Enum.NormalId.Top, Color = Color3.fromRGB(40, 40, 120), Stroke = 1 })
	end
	for i, p in { Vector3.new(-26, 0, -6), Vector3.new(-24, 0, 10), Vector3.new(26, 0, -4), Vector3.new(24, 0, 12) } do
		local h = spec.Height - (i % 2) * 8
		Part(m, { Name = "Pencil", Shape = Enum.PartType.Cylinder, Size = Vector3.new(h, 5, 5), CFrame = CFrame.new(c + p + Vector3.new(0, h / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Yellow })
		Part(m, { Name = "Eraser", Shape = Enum.PartType.Cylinder, Size = Vector3.new(3, 5.1, 5.1), CFrame = CFrame.new(c + p + Vector3.new(0, h + 1.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = C.Cap })
		Part(m, { Name = "Tip", Shape = Enum.PartType.Ball, Size = Vector3.new(4, 4, 4), Position = c + p + Vector3.new(0, 0.5, 0), Color = Color3.fromRGB(240, 210, 160) })
	end
	local hive = ball(m, c + Vector3.new(0, 21, 0), 10, Color3.fromRGB(170, 215, 255), nil, "PixieHive")
	hive.CanCollide = true
	for i = 1, 5 do
		local a = i * 1.25
		ball(m, hive.Position + Vector3.new(math.cos(a) * 4.6, (i - 3) * 1.3, math.sin(a) * 4.6), 2, C.Dark, nil, "HiveHole")
	end
	local alarm = ball(m, c + Vector3.new(0, 27.5, 0), 3, C.Red, Enum.Material.Neon, "AlarmLight")
	glow(alarm, C.Red, 50, 0).Name = "Alarm"
	local sign = Part(m, { Name = "Sign", Size = Vector3.new(30, 4, 0.5), Position = c + Vector3.new(0, 31, 12), Color = C.Dark })
	Label(sign, "📋 PRODUCTIVITY HQ", { Face = Enum.NormalId.Back, Color = C.Cyan })
	Label(sign, "📋 PRODUCTIVITY HQ", { Color = C.Cyan })
	m.Parent = world
end

function Builders.DeepSubconscious(spec, world)
	local m = model("DeepSubconscious")
	local c = Layout.Subconscious
	Part(m, { Name = "DreamFloor", Size = Vector3.new(50, 1, 40), Position = c + Vector3.new(0, 0.5, -5), Color = Color3.fromRGB(45, 15, 80), Material = Enum.Material.Neon, Transparency = 0.2 })
	for _, w in { { 0, -25, 52, 1 }, { -25.5, -5, 1, 40 }, { 25.5, -5, 1, 40 }, { -16, 15, 20, 1 }, { 16, 15, 20, 1 } } do
		Part(m, { Name = "DreamWall", Size = Vector3.new(w[3], 8, w[4]), Position = c + Vector3.new(w[1], 4, w[2]), Color = C.Purple, Material = Enum.Material.Neon, Transparency = 0.4 })
	end
	for _, x in { -6, 6 } do
		Part(m, { Name = "GatePost", Size = Vector3.new(2, spec.GateHeight, 2), Position = c + Vector3.new(x, spec.GateHeight / 2, 15), Color = C.Dark })
	end
	local field = Part(m, { Name = "GateField", Size = Vector3.new(10, spec.GateHeight - 2, 0.6), Position = c + Vector3.new(0, spec.GateHeight / 2 - 1, 15), Color = C.Purple, Material = Enum.Material.ForceField, Transparency = 0.1 })
	sparkles(field, Color3.fromRGB(200, 120, 255), 20, "Swirl")
	local sign = Part(m, { Name = "Sign", Size = Vector3.new(20, 3, 0.5), Position = c + Vector3.new(0, spec.GateHeight + 2, 15), Color = C.Dark })
	Label(sign, "🌀 DEEP SUBCONSCIOUS · BRAIN WASH 5", { Face = Enum.NormalId.Back, Color = Color3.fromRGB(210, 150, 255) })
	local rng = Random.new(9)
	for i = 1, spec.Clouds do
		ball(m, c + Vector3.new(rng:NextNumber(-22, 22), rng:NextNumber(10, 22), rng:NextNumber(-22, 10)), rng:NextNumber(4, 8), Color3.fromRGB(220, 200, 255), Enum.Material.Neon, "DreamCloud").Transparency = 0.5
	end
	for i, text in { "first meme", "2016 vine", "lost homework", "3 AM scroll" } do
		local mem = Part(m, { Name = "Memory", Size = Vector3.new(5, 3.5, 0.3), CFrame = CFrame.new(c + Vector3.new((i - 2.5) * 10, 12, -18)), Color = Color3.new(1, 1, 1), CanCollide = false })
		Label(mem, text, { Face = Enum.NormalId.Back, Color = C.Purple, Stroke = 1 })
	end
	local belt = Part(m, { Name = "DreamBelt", Size = Vector3.new(6, 0.6, 30), Position = c + Vector3.new(0, 1.2, -8), Color = C.Belt })
	Part(belt, { Name = "NerveLine", Size = Vector3.new(0.8, 0.2, 30), Position = belt.Position + Vector3.new(0, 0.35, 0), Color = Color3.fromRGB(200, 120, 255), Material = Enum.Material.Neon, CanCollide = false })
	m.Parent = world
end

function Builders.Scenery(spec, world)
	local m = model("FloatingThoughts")
	local rng = Random.new(42)
	for _ = 1, spec.ThoughtClouds do
		local p = Vector3.new(rng:NextNumber(-170, 170), rng:NextNumber(45, 75), rng:NextNumber(-170, 170))
		for k = 1, 3 do
			ball(m, p + Vector3.new((k - 2) * 4, (k % 2) * 1.5, 0), 7 - math.abs(k - 2) * 2, Color3.new(1, 1, 1), nil, "Cloud").Transparency = 0.15
		end
		ball(m, p + Vector3.new(6, -5, 0), 2, Color3.new(1, 1, 1), nil, "Trail").Transparency = 0.15
		ball(m, p + Vector3.new(8, -7.5, 0), 1.2, Color3.new(1, 1, 1), nil, "Trail").Transparency = 0.15
	end
	m.Parent = world
end

function WorldBuilder.BuildLighting()
	Lighting.Ambient = Color3.fromRGB(110, 70, 110)
	Lighting.OutdoorAmbient = Color3.fromRGB(160, 110, 160)
	Lighting.Brightness = 2.2
	Lighting.ClockTime = 14
	Lighting.GlobalShadows = true
	local function ensure(class, props)
		local e = Lighting:FindFirstChildOfClass(class) or Instance.new(class)
		for k, v in props do
			e[k] = v
		end
		e.Parent = Lighting
	end
	ensure("Atmosphere", { Density = 0.28, Offset = 0, Color = Color3.fromRGB(120, 20, 90), Decay = Color3.fromRGB(60, 8, 50), Glare = 0, Haze = 0 })
	ensure("BloomEffect", { Intensity = 0.5, Size = 24, Threshold = 2.2 })
	ensure("ColorCorrectionEffect", { Saturation = 0.45, Contrast = 0.12, TintColor = Color3.fromRGB(255, 240, 250) })
	for _, name in { "DepthOfField", "SunRays" } do
		local e = Lighting:FindFirstChild(name)
		if e then
			e:Destroy()
		end
	end
end

WorldBuilder.Sheet = {
	{ Builder = "BrainFloor", Size = 420, Ridges = 70, Puddles = 26, Nerves = 18 },
	{ Builder = "SkullWall", Radius = 205, Height = 80, Segments = 48 },
	{ Builder = "MemeLobe", Height = 60, Folds = 9, Neurons = 18 },
	{ Builder = "SynapseBelt", Width = 8 },
	{ Builder = "Lobe", Width = 40, Depth = 30, Count = 8 },
	{ Builder = "BrainStemPlaza", Radius = 30 },
	{ Builder = "NeonSign", Width = 50 },
	{ Builder = "MostRottedBoard", Width = 20, Height = 14 },
	{ Builder = "BrainWheel", Width = 12 },
	{ Builder = "DopamineMart", Height = 12, Kiosks = {
		{ Name = "GearKiosk", Title = "GEAR", Color = C.Cap },
		{ Name = "UpgradeKiosk", Title = "UPGRADES", Color = C.Yellow },
		{ Name = "BrainWashKiosk", Title = "BRAIN WASH", Color = C.Cyan },
	} },
	{ Builder = "MemeBlender", Height = 14 },
	{ Builder = "BrainTeaserCorner", TrackLength = 50, Blades = 6 },
	{ Builder = "ProductivityHQ", Height = 40 },
	{ Builder = "DeepSubconscious", GateHeight = 20, Clouds = 10 },
	{ Builder = "Scenery", ThoughtClouds = 16 },
}

function WorldBuilder.BuildWorld()
	local existing = workspace:FindFirstChild("BrainWorld")
	if existing then
		return existing
	end
	for _, name in { "Baseplate", "SpawnLocation" } do
		local old = workspace:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end
	local world = Instance.new("Folder")
	world.Name = "BrainWorld"
	world.Parent = workspace
	for _, spec in WorldBuilder.Sheet do
		for i = 1, spec.Count or 1 do
			Builders[spec.Builder](spec, world, i)
			task.wait()
		end
	end
	WorldBuilder.BuildLighting()
	return world
end

return WorldBuilder
