local RarityConfig = require(script.Parent.RarityConfig)
local MutationConfig = require(script.Parent.MutationConfig)
local BrainrotCatalog = require(script.Parent.BrainrotCatalog)
local NumberFormat = require(script.Parent.NumberFormat)

local BrainrotModelKit = {}

local BRAIN = Color3.fromHex("FF9EC7")
local BRAIN_FOLD = Color3.fromHex("C9407A")
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.fromRGB(20, 15, 25)
local BLUSH = Color3.fromRGB(255, 120, 160)
local GOLD = Color3.fromRGB(255, 200, 40)
local GOO = Color3.fromRGB(110, 255, 70)
local RAINBOW = { Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 160, 40), Color3.fromRGB(255, 230, 60), Color3.fromRGB(80, 220, 90), Color3.fromRGB(70, 160, 255), Color3.fromRGB(170, 90, 255) }

local BODY_SIZES = {
	Blob = Vector3.new(3, 3, 3), Tall = Vector3.new(2.6, 3.8, 2.6), Wide = Vector3.new(3.8, 2.4, 3.2),
	Block = Vector3.new(3.2, 2.6, 2.6), Wedge = Vector3.new(3.2, 2.6, 3), Long = Vector3.new(2.6, 2.4, 4.4),
}

local Ctx = {}
Ctx.__index = Ctx

function Ctx:Part(name, size, cf, color, material, shape)
	local p = Instance.new(shape == "Wedge" and "WedgePart" or "Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape == "Ball" then
		p.Shape = Enum.PartType.Ball
	elseif shape == "Cyl" then
		p.Shape = Enum.PartType.Cylinder
	elseif shape == "Ell" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = p
	end
	p.Parent = self.Model
	return p
end

function Ctx:E(name, size, pos, color, material)
	return self:Part(name, size, CFrame.new(pos), color, material, "Ell")
end

function Ctx:Rod(name, a, b, d, color, material)
	local len = (b - a).Magnitude
	return self:Part(name, Vector3.new(len, d, d), CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, math.rad(90), 0), color, material, "Cyl")
end

function Ctx:Keep(p)
	p:SetAttribute("Keep", true)
	return p
end

function Ctx:Surf(x, y)
	if self.Def.Body == "Block" or self.Def.Body == "Wedge" then
		return -self.D / 2
	end
	local k = 1 - (x / (self.W / 2)) ^ 2 - (y / (self.H / 2)) ^ 2
	return -self.D / 2 * math.sqrt(math.max(0.04, k))
end

function Ctx:Particles(parent, color, rate, size, speed, name)
	local e = Instance.new("ParticleEmitter")
	e.Name = name or "Fx"
	e.Color = typeof(color) == "ColorSequence" and color or ColorSequence.new(color)
	e.LightEmission = 0.8
	e.Rate = rate
	e.Lifetime = NumberRange.new(0.8, 1.6)
	e.Speed = NumberRange.new(speed or 1, (speed or 1) * 2)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size or 0.3), NumberSequenceKeypoint.new(1, 0) })
	e.Parent = parent
	return e
end

function Ctx:Text(parent, text, color, offsetY, sizePx)
	local bb = Instance.new("BillboardGui")
	bb.Name = "PropText"
	bb.Size = UDim2.fromOffset(sizePx or 40, sizePx or 40)
	bb.StudsOffsetWorldSpace = Vector3.new(0, offsetY or 0, 0)
	bb.LightInfluence = 0
	bb.MaxDistance = 90
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextScaled = true
	t.Font = Enum.Font.FredokaOne
	t.TextColor3 = color
	t.TextStrokeTransparency = 0
	t.Parent = bb
	bb.Parent = parent
	return bb
end

local function darker(c, k)
	return c:Lerp(BLACK, k or 0.3)
end

local Pre = {
	longLegs = function(c)
		c.Lift = 1.8
	end,
	doubleBrain = function(c)
		c.CapScale = 1.8
	end,
	giantBrain = function(c)
		c.CapScale = 2.1
	end,
	ghostTail = function(c)
		c.NoFeet = true
	end,
	cone = function(c)
		c.NoFeet = true
		c.Lift = 2.4
	end,
	bowl = function(c)
		c.NoFeet = true
		c.Lift = 0.6
	end,
	brainBody = function(c)
		c.Color = BRAIN
	end,
}

local Features = {}

function Features.roundEars(c, color)
	for _, sx in { -1, 1 } do
		c:Part("Ear", Vector3.one * 1.2, CFrame.new(sx * c.W * 0.33, c.Top - 0.25, 0.1), color or c.Color, nil, "Ball")
		c:E("EarInner", Vector3.new(0.7, 0.7, 0.2), Vector3.new(sx * c.W * 0.33, c.Top - 0.25, -0.5), color and darker(color, 0.4) or BLUSH)
	end
end
function Features.blackEars(c)
	Features.roundEars(c, BLACK)
end
function Features.bigRoundEars(c)
	for _, sx in { -1, 1 } do
		c:Part("Ear", Vector3.one * 1.9, CFrame.new(sx * c.W * 0.45, c.Top - 0.4, 0.2), c.Color, nil, "Ball")
		c:E("EarInner", Vector3.new(1.2, 1.2, 0.3), Vector3.new(sx * c.W * 0.45, c.Top - 0.4, -0.65), WHITE)
	end
end
function Features.thinTail(c)
	c:Rod("Tail", Vector3.new(0, c.Cy - c.H * 0.3, c.D * 0.45), Vector3.new(0.6, c.Cy, c.D * 0.5 + 1.6), 0.25, BLUSH)
end
function Features.tail(c)
	c:Rod("Tail", Vector3.new(0, c.Cy - c.H * 0.2, c.D * 0.45), Vector3.new(0, c.Cy + 0.6, c.D * 0.5 + 1.5), 0.6, c.Color)
	c:Part("TailTip", Vector3.one * 0.8, CFrame.new(0, c.Cy + 0.6, c.D * 0.5 + 1.5), darker(c.Color, 0.2), nil, "Ball")
end
function Features.whiteTail(c)
	c:E("Tail", Vector3.new(1, 1, 2.2), Vector3.new(0.4, c.Cy - 0.3, c.D * 0.5 + 0.8), c.Color)
	c:Part("TailTip", Vector3.one * 0.9, CFrame.new(0.4, c.Cy - 0.3, c.D * 0.5 + 1.9), WHITE, nil, "Ball")
end
function Features.brainShell(c)
	local pos = Vector3.new(0, c.Cy + c.H * 0.35, c.D * 0.15)
	c:E("Shell", Vector3.new(c.W * 0.95, c.H * 1.2, c.D * 0.5), pos, BRAIN)
	for i = -1, 1 do
		c:E("ShellFold", Vector3.new(0.2, c.H * 0.9, c.D * 0.52), pos + Vector3.new(i * 0.5, 0, 0), BRAIN_FOLD)
	end
	c.CapY = c.Top + 0.6
end
function Features.spots(c)
	for i, p in { { -0.8, 0.3 }, { 0.9, -0.2 }, { 0.2, 0.8 }, { -0.4, -0.6 } } do
		c:E("Spot", Vector3.new(0.6, 0.5, 0.2), Vector3.new(p[1], c.Cy + p[2], c:Surf(p[1], p[2]) + 0.05), darker(c.Color, 0.35))
	end
end
function Features.beak(c)
	c:E("Beak", Vector3.new(0.9, 0.5, 0.9), Vector3.new(0, c.Cy - c.H * 0.02, c:Surf(0, -c.H * 0.02) - 0.25), Color3.fromRGB(255, 150, 30))
end
function Features.curvedBeak(c)
	local base = Vector3.new(0, c.Cy, c:Surf(0, 0) - 0.2)
	c:Rod("Beak", base, base + Vector3.new(0, -0.6, -1), 0.5, Color3.fromRGB(255, 190, 200))
	c:Part("BeakTip", Vector3.one * 0.5, CFrame.new(base + Vector3.new(0, -0.65, -1.05)), BLACK, nil, "Ball")
end
function Features.chips(c)
	for _, p in { { -0.9, 0.4 }, { 0.8, 0.5 }, { 0.2, -0.5 }, { -1.2, -0.3 }, { 1.3, -0.2 } } do
		c:E("Chip", Vector3.new(0.45, 0.45, 0.3), Vector3.new(p[1], c.Cy + p[2], c:Surf(p[1], p[2])), Color3.fromRGB(80, 45, 25))
	end
end
function Features.holes(c)
	for _, p in { { -0.9, 0.5 }, { 0.8, 0.3 }, { 0.1, -0.6 }, { -0.5, -0.1 } } do
		c:E("Hole", Vector3.new(0.6, 0.6, 0.2), Vector3.new(p[1], c.Cy + p[2], -c.D / 2 - 0.02), darker(c.Color, 0.25))
	end
end
function Features.dotHoles(c)
	for i = 0, 5 do
		local x, y = -1 + (i % 3) * 1, (i < 3) and 0.7 or -0.75
		c:Part("Dot", Vector3.new(0.25, 0.25, 0.1), CFrame.new(x, c.Cy + y, -c.D / 2 - 0.03), darker(c.Color, 0.4))
	end
end
function Features.smallHorns(c)
	for _, sx in { -1, 1 } do
		c:Rod("Horn", Vector3.new(sx * 0.6, c.Top - 0.3, 0.2), Vector3.new(sx * 1.0, c.Top + 0.7, 0.6), 0.35, Color3.fromRGB(220, 200, 160))
	end
end
function Features.horns(c)
	for _, sx in { -1, 1 } do
		c:Rod("Horn", Vector3.new(sx * 0.8, c.Top - 0.4, 0), Vector3.new(sx * 1.4, c.Top + 0.9, 0.3), 0.45, Color3.fromRGB(255, 230, 180))
	end
end
function Features.beard(c)
	c:E("Beard", Vector3.new(0.8, 1, 0.6), Vector3.new(0, c.Cy - c.H * 0.4, c:Surf(0, -c.H * 0.4) - 0.1), WHITE)
end
function Features.mushroomCap(c)
	local y = c.Top + 0.2
	c:E("MushroomCap", Vector3.new(c.W * 1.6, 1.6, c.D * 1.6), Vector3.new(0, y, 0), Color3.fromRGB(230, 50, 50))
	for i = 1, 5 do
		local a = i * 1.25
		c:E("CapDot", Vector3.new(0.5, 0.3, 0.5), Vector3.new(math.cos(a) * 1.4, y + 0.5, math.sin(a) * 1.4), WHITE)
	end
	c.CapY = y + 0.6
end
function Features.leafTop(c)
	c:Rod("Stem", Vector3.new(0.6, c.Top - 0.1, 0), Vector3.new(0.7, c.Top + 0.5, 0), 0.2, Color3.fromRGB(60, 140, 50))
	c:E("Leaf", Vector3.new(1.4, 0.2, 0.7), Vector3.new(1.2, c.Top + 0.45, 0), Color3.fromRGB(80, 190, 70))
end
function Features.basilLeaf(c)
	c:E("Basil", Vector3.new(1.3, 0.2, 0.8), Vector3.new(-0.9, c.Top - 0.05, 0), Color3.fromRGB(60, 170, 60))
end
function Features.stem(c)
	c:Rod("Stem", Vector3.new(0.5, c.Top - 0.2, 0), Vector3.new(0.9, c.Top + 0.9, 0.2), 0.35, Color3.fromRGB(60, 150, 50))
end
function Features.floppyEars(c)
	for _, sx in { -1, 1 } do
		c:Part("Ear", Vector3.new(0.5, 1.8, 0.9), CFrame.new(sx * (c.W * 0.5), c.Cy + c.H * 0.1, 0) * CFrame.Angles(0, 0, sx * 0.25), darker(c.Color, 0.25), nil, "Ell")
	end
end
function Features.longEars(c)
	for _, sx in { -1, 1 } do
		local base = Vector3.new(sx * 0.6, c.Top - 0.2, 0.2)
		c:Part("Ear", Vector3.new(0.7, 2.6, 0.4), CFrame.new(base + Vector3.new(sx * 0.2, 1.1, 0)) * CFrame.Angles(0, 0, -sx * 0.15), c.Color, nil, "Ell")
		c:Part("EarInner", Vector3.new(0.35, 1.9, 0.2), CFrame.new(base + Vector3.new(sx * 0.2, 1.1, -0.15)) * CFrame.Angles(0, 0, -sx * 0.15), BLUSH, nil, "Ell")
	end
end
function Features.bigEars(c)
	for _, sx in { -1, 1 } do
		c:Part("Ear", Vector3.new(0.3, 2.6, 2.2), CFrame.new(sx * c.W * 0.55, c.Cy + 0.3, 0.2) * CFrame.Angles(0, sx * 0.3, 0), c.Color, nil, "Ell")
	end
end
function Features.pointyEars(c)
	for _, sx in { -1, 1 } do
		c:Part("Ear", Vector3.new(0.4, 1.4, 1), CFrame.new(sx * 0.8, c.Top + 0.2, 0) * CFrame.Angles(0, math.rad(90), 0), c.Color, nil, "Wedge")
	end
end
function Features.catEars(c)
	Features.pointyEars(c)
end
function Features.bigCheeks(c)
	for _, sx in { -1, 1 } do
		c:E("Cheek", Vector3.new(1.2, 1, 1), Vector3.new(sx * c.W * 0.36, c.Cy - c.H * 0.15, c:Surf(c.W * 0.36, -c.H * 0.15) + 0.15), c.Belly)
	end
end
function Features.fanTail(c)
	for i = 1, 6 do
		local a = math.rad(-75 + (i - 1) * 30)
		c:Part("Feather", Vector3.new(0.9, 2.6, 0.3), CFrame.new(0, c.Cy + 0.3, c.D * 0.45) * CFrame.Angles(0, 0, a) * CFrame.new(0, 1.3, 0), RAINBOW[i], nil, "Ell")
	end
end
function Features.spikes(c)
	for i = 1, 9 do
		local a = math.rad(-60 + (i - 1) * 15)
		local dir = Vector3.new(math.sin(a), math.cos(a) * 0.8, 0.6).Unit
		local base = Vector3.new(0, c.Cy, 0) + dir * c.W * 0.45
		c:Rod("Spike", base, base + dir * 1.1, 0.3, darker(c.Color, 0.35))
	end
end
function Features.pepperoni(c)
	for _, p in { { -0.8, 0.4 }, { 0.7, 0.2 }, { -0.1, -0.6 } } do
		c:Part("Pepperoni", Vector3.new(0.1, 0.8, 0.8), CFrame.new(p[1], c.Cy + p[2], -c.D / 2 - 0.05) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(200, 40, 30), nil, "Cyl")
	end
end
function Features.layers(c)
	for i = -1, 1 do
		c:Part("Layer", Vector3.new(c.W + 0.1, 0.25, c.D + 0.1), CFrame.new(0, c.Cy + i * 0.7, 0), i == 0 and Color3.fromRGB(200, 50, 40) or c.Belly)
	end
end
function Features.crimped(c)
	for i = -3, 3 do
		c:Part("Crimp", Vector3.new(0.35, 0.3, c.D + 0.3), CFrame.new(i * 0.45, c.Cy - c.H / 2 + 0.1, 0), darker(c.Color, 0.15))
	end
end
function Features.spaghettiHair(c)
	for i = 1, 10 do
		local a = i / 10 * math.pi * 2
		local top = Vector3.new(math.cos(a) * 0.9, c.Top + 0.4, math.sin(a) * 0.9)
		c:Rod("Noodle", top, top + Vector3.new(math.cos(a) * 0.9, -1.8, math.sin(a) * 0.9), 0.18, Color3.fromRGB(255, 220, 110))
	end
end
function Features.doubleBrain(_c) end
function Features.giantBrain(_c) end
function Features.ghostTail(c)
	for i = 1, 3 do
		c:E("Wisp", Vector3.new(c.W * (1 - i * 0.22), 0.8, c.D * (1 - i * 0.22)), Vector3.new(math.sin(i) * 0.3, c.Cy - c.H / 2 - i * 0.4 + 0.5, 0), c.Color).Transparency = 0.4
	end
	c.Body.Transparency = 0.4
end
function Features.cone(c)
	for i = 0, 4 do
		local w = 2.2 - i * 0.45
		c:Part("Cone", Vector3.new(0.6, w, w), CFrame.new(0, c.Lift - i * 0.5 + 0.2, 0) * CFrame.Angles(0, 0, math.rad(90)), c.Belly, nil, "Cyl")
	end
end
function Features.ring(c)
	for i = 1, 10 do
		local a = i / 10 * math.pi * 2
		c:Part("RingBump", Vector3.one * 0.9, CFrame.new(math.cos(a) * c.W * 0.45, c.Cy - 0.3, math.sin(a) * c.D * 0.45), darker(c.Color, 0.1), nil, "Ball")
	end
end
function Features.claws(c)
	for _, sx in { -1, 1 } do
		local arm = Vector3.new(sx * c.W * 0.5, c.Cy, -0.3)
		c:Rod("Arm", arm, arm + Vector3.new(sx * 0.8, 1.2, 0), 0.45, c.Color)
		local claw = arm + Vector3.new(sx * 1, 1.8, 0)
		c:E("Claw", Vector3.new(1.3, 1.1, 0.8), claw, darker(c.Color, 0.1))
		c:Part("Pincer", Vector3.new(0.4, 0.8, 0.5), CFrame.new(claw + Vector3.new(0, 0.7, 0)) * CFrame.Angles(0, 0, sx * 0.4), darker(c.Color, 0.3), nil, "Ell")
	end
end
function Features.backFin(c)
	c:Part("Fin", Vector3.new(0.4, 1.6, 1.6), CFrame.new(0, c.Top + 0.5, 0.6) * CFrame.Angles(0, math.rad(180), 0), darker(c.Color, 0.2), nil, "Wedge")
end
function Features.teeth(c)
	for i = -2, 2 do
		c:Keep(c:Part("Tooth", Vector3.new(0.22, 0.3, 0.1), CFrame.new(i * 0.25, c.Cy - c.H * 0.22, c:Surf(i * 0.25, -c.H * 0.22) - 0.12) * CFrame.Angles(math.rad(180), 0, 0), WHITE, nil, "Wedge"))
	end
end
local function tentacles(c, n)
	for i = 1, n do
		local a = i / n * math.pi * 2
		local a0 = Vector3.new(math.cos(a) * c.W * 0.32, c.Cy - c.H * 0.35, math.sin(a) * c.D * 0.32)
		local a1 = a0 + Vector3.new(math.cos(a) * 0.9, -0.9, math.sin(a) * 0.9)
		local a2 = a1 + Vector3.new(math.cos(a + 0.6) * 0.7, -0.2, math.sin(a + 0.6) * 0.7)
		c:Rod("Tentacle", a0, a1, 0.55, c.Color)
		c:Rod("Tentacle", a1, a2, 0.42, darker(c.Color, 0.1))
	end
	c.NoFeet = true
end
function Features.tentacles6(c)
	tentacles(c, 6)
end
function Features.tentacles8(c)
	tentacles(c, 8)
end
function Features.longArms(c)
	for _, sx in { -1, 1 } do
		local s = Vector3.new(sx * c.W * 0.45, c.Cy + 0.3, -0.5)
		c:Rod("Arm", s, s + Vector3.new(sx * 0.6, -1.8, -0.8), 0.45, c.Color)
		c:Rod("Claw", s + Vector3.new(sx * 0.6, -1.8, -0.8), s + Vector3.new(sx * 0.6, -2.2, -1.3), 0.2, BLACK)
	end
end
function Features.longLegs(c)
	for _, sx in { -1, 1 } do
		c:Rod("Leg", Vector3.new(sx * 0.5, 0.2, 0), Vector3.new(sx * 0.5, c.Lift + 0.7, 0), 0.25, Color3.fromRGB(255, 120, 170))
	end
end
function Features.longNeck(c)
	local neckTop = Vector3.new(0, c.Top + 1.6, -0.3)
	c:Rod("Neck", Vector3.new(0, c.Top - 0.5, -0.2), neckTop, 1.2, c.Color)
	c:Part("Head", Vector3.one * 1.8, CFrame.new(neckTop + Vector3.new(0, 0.4, -0.2)), c.Color, nil, "Ball")
	for _, sx in { -1, 1 } do
		c:Keep(c:E("Eye", Vector3.new(0.5, 0.55, 0.3), neckTop + Vector3.new(sx * 0.4, 0.6, -1), WHITE))
		c:Keep(c:E("Pupil", Vector3.new(0.3, 0.32, 0.2), neckTop + Vector3.new(sx * 0.4, 0.55, -1.12), BLACK))
	end
	c.CapY = neckTop.Y + 1.1
	c.CapScale = 0.8
end
function Features.fluffyHead(c)
	local y = (c.CapY or c.Top) - 0.2
	for i = 1, 6 do
		local a = i / 6 * math.pi * 2
		c:Part("Fluff", Vector3.one * 0.9, CFrame.new(math.cos(a) * 0.7, y, math.sin(a) * 0.7 - 0.4), WHITE, nil, "Ball")
	end
end
function Features.pandaPatches(_c) end
function Features.orangeFeet(_c) end
function Features.mane(c)
	for i = 1, 14 do
		local a = i / 14 * math.pi * 2
		c:Part("Mane", Vector3.one * 1.3, CFrame.new(math.cos(a) * c.W * 0.55, c.Cy + 0.2 + math.sin(a) * c.H * 0.55, 0.4), Color3.fromRGB(200, 110, 40), nil, "Ball")
	end
end
function Features.stripes(c)
	for i = -2, 2 do
		c:Part("Stripe", Vector3.new(0.25, c.H * 0.7, c.D * 0.85), CFrame.new(i * 0.55, c.Cy + 0.1, 0.25), BLACK, nil, "Ell")
	end
end
function Features.wings(c, color, mat)
	for _, sx in { -1, 1 } do
		c:Part("Wing", Vector3.new(0.4, 1.8, 2.6), CFrame.new(sx * c.W * 0.55, c.Cy + 0.4, 0.4) * CFrame.Angles(0, 0, -sx * 0.6), color or darker(c.Color, 0.15), mat, "Ell")
	end
end
function Features.flameWings(c)
	Features.wings(c, Color3.fromRGB(255, 120, 30), Enum.Material.Neon)
end
function Features.angelWings(c)
	Features.wings(c, WHITE, Enum.Material.Neon)
end
function Features.spout(c)
	for i = 1, 3 do
		c:Rod("Spout", Vector3.new(0, c.Top, 0), Vector3.new((i - 2) * 0.6, c.Top + 1.6, 0), 0.25, Color3.fromRGB(120, 210, 255), Enum.Material.Neon).Transparency = 0.3
	end
end
function Features.snout(c)
	c:E("Snout", Vector3.new(1.6, 0.9, 2.2), Vector3.new(0, c.Cy - 0.3, -c.D / 2 - 0.6), c.Color)
end
function Features.trunk(c)
	local s = Vector3.new(0, c.Cy - 0.1, c:Surf(0, -0.1) - 0.2)
	local m = s + Vector3.new(0, -0.9, -0.6)
	c:Rod("Trunk", s, m, 0.6, c.Color)
	c:Rod("Trunk", m, m + Vector3.new(0, -0.5, -0.6), 0.5, c.Color)
	c.TrunkTip = m + Vector3.new(0, -0.5, -0.6)
end
function Features.tusks(c)
	for _, sx in { -1, 1 } do
		c:Rod("Tusk", Vector3.new(sx * 0.5, c.Cy - 0.5, c:Surf(0.5, -0.5)), Vector3.new(sx * 0.8, c.Cy - 0.2, c:Surf(0.5, -0.5) - 1.1), 0.3, WHITE)
	end
end
function Features.rainbowMane(c)
	for i = 1, 6 do
		c:Part("Mane", Vector3.one * 0.9, CFrame.new(0, c.Top - 0.1 - i * 0.15, -0.3 + i * 0.4), RAINBOW[i], Enum.Material.Neon, "Ball")
	end
end
function Features.unicornHorn(c)
	local base = Vector3.new(0, c.Cy + c.H * 0.35, c:Surf(0, c.H * 0.35) + 0.2)
	c:Rod("Horn", base, base + Vector3.new(0, 1.3, -0.5), 0.45, GOLD, Enum.Material.Neon)
	c:Rod("HornTip", base + Vector3.new(0, 1.3, -0.5), base + Vector3.new(0, 1.9, -0.75), 0.22, GOLD, Enum.Material.Neon)
end
function Features.fur(c)
	for i = 1, 8 do
		local a = i / 8 * math.pi * 2
		c:E("Fur", Vector3.new(1, 1.4, 0.8), Vector3.new(math.cos(a) * c.W * 0.45, c.Cy - 0.5, math.sin(a) * c.D * 0.45 + 0.2), darker(c.Color, 0.15))
	end
end
function Features.brainBody(c)
	for i = 1, 6 do
		local a = i / 6 * math.pi
		c:Part("BodyFold", Vector3.new(0.25, c.H * 0.95, c.D * 1.02), CFrame.new(0, c.Cy, 0) * CFrame.Angles(0, a, 0) * CFrame.new(0.3, 0, 0), BRAIN_FOLD, nil, "Ell")
	end
end
function Features.grassHair(c)
	for i = 1, 12 do
		local a = i / 12 * math.pi * 2
		local b = Vector3.new(math.cos(a) * 1, c.Top - 0.2, math.sin(a) * 1)
		c:Rod("Grass", b, b + Vector3.new(math.cos(a) * 0.4, 1.2, math.sin(a) * 0.4), 0.2, Color3.fromRGB(70, 200, 60))
	end
end
function Features.scaredFace(c)
	c:Keep(c:E("SweatDrop", Vector3.new(0.3, 0.5, 0.3), Vector3.new(c.W * 0.42, c.Cy + 0.6, c:Surf(c.W * 0.42, 0.6) - 0.1), Color3.fromRGB(120, 200, 255)))
end
function Features.sharpJaw(c)
	c:Part("Jaw", Vector3.new(c.W * 0.55, 0.5, 0.6), CFrame.new(0, c.Cy - c.H * 0.32, c:Surf(0, -c.H * 0.32) - 0.05), darker(c.Color, 0.1))
end
function Features.slickHair(c)
	c:E("Hair", Vector3.new(c.W * 0.8, 0.7, c.D * 0.7), Vector3.new(0, c.Top - 0.15, 0.4), BLACK, Enum.Material.Glass)
end
function Features.riceDots(c)
	for i = 1, 10 do
		local a = i * 2.4
		local x, y = math.cos(a) * 1.3, 0.2 + math.sin(a) * 0.5
		c:E("Rice", Vector3.new(0.25, 0.15, 0.4), Vector3.new(x, c.Cy + y, c:Surf(x, y) + 0.02), WHITE)
	end
end
function Features.bowl(c)
	c:Part("Bowl", Vector3.new(1.2, c.W * 1.05, c.W * 1.05), CFrame.new(0, 0.7, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(240, 240, 255), nil, "Cyl")
	c:Part("BowlBase", Vector3.new(0.4, c.W * 0.6, c.W * 0.6), CFrame.new(0, 0.1, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(200, 60, 60), nil, "Cyl")
end
function Features.comb(c)
	for i = -1, 1 do
		c:Part("Comb", Vector3.one * 0.7, CFrame.new(i * 0.4, c.Top + 0.1, 0.6), Color3.fromRGB(230, 40, 40), nil, "Ball")
	end
end
function Features.cyclops(_c) end
function Features.gooDrips(c)
	for i = 1, 6 do
		local a = i / 6 * math.pi * 2
		c:E("GooDrip", Vector3.new(0.35, 1.1, 0.35), Vector3.new(math.cos(a) * c.W * 0.42, c.Cy - c.H * 0.3, math.sin(a) * c.D * 0.42), GOO, Enum.Material.Neon)
	end
end
function Features.manyEyes(_c) end
function Features.jitter(c)
	c.Model:SetAttribute("Jitter", true)
end
for _, faceFlag in { "topEyes", "sleepyEyes", "wideEyes", "calmEyes", "eyeBags" } do
	Features[faceFlag] = function() end
end

local Props = {}

local function headSide(c, sx)
	return Vector3.new(sx * (c.W * 0.55 + 0.4), c.Cy, -0.3)
end

function Props.thoughtBubble(c)
	local p = Vector3.new(1.4, (c.CapY or c.Top) + 2.2, 0)
	for i, s in { 1.2, 1.5, 1.1 } do
		c:Part("Thought", Vector3.one * s, CFrame.new(p + Vector3.new((i - 2) * 0.8, (i % 2) * 0.3, 0)), WHITE, nil, "Ball")
	end
	c:Part("ThoughtTrail", Vector3.one * 0.4, CFrame.new(p + Vector3.new(-0.9, -1.1, 0)), WHITE, nil, "Ball")
	c:Text(c.Body, "🧀", BLACK, (c.CapY or c.Top) + 2.4 - c.Cy, 26)
end
function Props.mirror(c)
	local h = headSide(c, 1)
	c:Part("MirrorGlass", Vector3.new(0.2, 1.4, 1.4), CFrame.new(h + Vector3.new(0.3, 0.6, -0.4)) * CFrame.Angles(0, math.rad(60), 0), Color3.fromRGB(200, 240, 255), Enum.Material.Glass, "Cyl")
	c:Rod("MirrorHandle", h + Vector3.new(0.3, -0.1, -0.4), h + Vector3.new(0.3, -0.9, -0.4), 0.25, Color3.fromRGB(255, 120, 180))
end
function Props.loadingSign(c)
	local p = Vector3.new(1.8, c.Top + 0.8, 0.5)
	c:Rod("SignPole", Vector3.new(1.8, 0.2, 0.5), p, 0.15, Color3.fromRGB(120, 80, 50))
	local sign = c:Part("Sign", Vector3.new(1.6, 0.9, 0.1), CFrame.new(p + Vector3.new(0, 0.4, 0)), WHITE)
	c:Text(sign, "⏳ LOADING", BLACK, 0, 30)
end
function Props.pillow(c)
	c:E("Pillow", Vector3.new(2.2, 0.7, 1.4), Vector3.new(c.W * 0.5 + 0.6, 0.35, 0.3), WHITE)
end
function Props.spinningQuestion(c)
	c:Text(c.Body, "?", Color3.fromRGB(255, 220, 60), (c.CapY or c.Top) + 1.8 - c.Cy, 40)
end
function Props.questionText(c)
	c:Text(c.Body, "???", Color3.fromRGB(255, 220, 60), (c.CapY or c.Top) + 2 - c.Cy, 50)
end
function Props.bufferRing(c)
	local center = Vector3.new(0, (c.CapY or c.Top) + 2, 0)
	for i = 1, 8 do
		local a = i / 8 * math.pi * 2
		c:Part("Buffer", Vector3.one * 0.35, CFrame.new(center + Vector3.new(math.cos(a) * 0.8, math.sin(a) * 0.8, 0)), Color3.fromRGB(255, 255, 255):Lerp(Color3.fromRGB(80, 80, 90), i / 8), Enum.Material.Neon, "Ball")
	end
end
function Props.steam(c)
	c:Particles(c.Body, WHITE, 6, 0.8, 1.5, "Steam").EmissionDirection = Enum.NormalId.Top
end
function Props.nightCap(c)
	local y = (c.CapY or c.Top) + 0.5
	for i = 0, 3 do
		local w = 1.4 - i * 0.3
		c:Part("NightCap", Vector3.new(0.4, w, w), CFrame.new(0.9 + i * 0.15, y + i * 0.35, 0) * CFrame.Angles(0, 0, math.rad(90 - 20)), Color3.fromRGB(70, 90, 200), nil, "Cyl")
	end
	c:Part("Pompom", Vector3.one * 0.5, CFrame.new(1.6, y + 1.5, 0), WHITE, nil, "Ball")
	c:Text(c.Body, "Zzz", Color3.fromRGB(180, 200, 255), y + 2 - c.Cy, 34)
end
function Props.fogCloud(c)
	for i = 1, 3 do
		c:Part("Fog", Vector3.one * (1 + i * 0.3), CFrame.new(-1.6 + i * 0.4, (c.CapY or c.Top) + 1 + i * 0.2, 0.6), Color3.fromRGB(190, 190, 200), nil, "Ball").Transparency = 0.35
	end
end
function Props.fogAura(c)
	c:Particles(c.Body, Color3.fromRGB(200, 200, 210), 10, 1.4, 0.5, "BrainFog").LightEmission = 0
end
function Props.bandage(c)
	local p = Vector3.new(-0.7, (c.CapY or c.Top) + 0.2, -0.4)
	c:Part("Bandage", Vector3.new(1.3, 0.3, 0.12), CFrame.new(p) * CFrame.Angles(0, 0, 0.6), WHITE)
	c:Part("Bandage", Vector3.new(1.3, 0.3, 0.12), CFrame.new(p) * CFrame.Angles(0, 0, -0.6), WHITE)
end
function Props.sweat(c)
	for _, sx in { -1, 1 } do
		c:Keep(c:E("Sweat", Vector3.new(0.3, 0.5, 0.3), Vector3.new(sx * c.W * 0.45, c.Cy + c.H * 0.3, -c.D * 0.25), Color3.fromRGB(120, 200, 255)))
	end
end
function Props.phone(c)
	local p = Vector3.new(0, c.Cy - c.H * 0.1, c:Surf(0, -c.H * 0.1) - 0.5)
	c:Part("Phone", Vector3.new(0.9, 1.5, 0.15), CFrame.new(p) * CFrame.Angles(math.rad(-25), 0, 0), BLACK)
	c:Keep(c:Part("PhoneScreen", Vector3.new(0.75, 1.3, 0.05), CFrame.new(p) * CFrame.Angles(math.rad(-25), 0, 0) * CFrame.new(0, 0, 0.09), Color3.fromRGB(120, 200, 255), Enum.Material.Neon))
end
function Props.paperBag(c)
	c:Part("PaperBag", Vector3.new(1.2, 1, 1.2), CFrame.new(1, (c.CapY or c.Top) + 0.4, 0.3) * CFrame.Angles(0, 0, -0.4), Color3.fromRGB(200, 160, 110))
end
function Props.sunglasses(c)
	local y = c.Cy + c.H * 0.12
	for _, sx in { -1, 1 } do
		c:Keep(c:Part("Lens", Vector3.new(1, 0.6, 0.15), CFrame.new(sx * c.W * 0.21, y, c:Surf(c.W * 0.21, c.H * 0.12) - 0.35), BLACK, Enum.Material.Glass))
	end
	c:Keep(c:Part("Bridge", Vector3.new(c.W * 0.5, 0.12, 0.1), CFrame.new(0, y + 0.15, c:Surf(0, c.H * 0.12) - 0.35), BLACK))
end
function Props.stickyNote(c)
	c:Part("StickyNote", Vector3.new(0.9, 0.9, 0.05), CFrame.new(c.W * 0.3, c.Cy - 0.3, c:Surf(c.W * 0.3, -0.3) - 0.05) * CFrame.Angles(0, 0, 0.2), Color3.fromRGB(255, 240, 90))
end
function Props.coffee(c)
	local h = headSide(c, -1)
	c:Part("Cup", Vector3.new(1, 0.8, 0.8), CFrame.new(h) * CFrame.Angles(0, 0, math.rad(90)), WHITE, nil, "Cyl")
	c:Part("Coffee", Vector3.new(0.05, 0.7, 0.7), CFrame.new(h + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(90, 50, 30), nil, "Cyl")
	c:Particles(c.Body, WHITE, 2, 0.4, 1, "CoffeeSteam")
end
function Props.bulbOff(c)
	local y = (c.CapY or c.Top) + 1.8
	c:Part("Bulb", Vector3.one * 1, CFrame.new(0, y, 0), Color3.fromRGB(230, 230, 200), Enum.Material.Glass, "Ball")
	c:Part("BulbBase", Vector3.new(0.5, 0.5, 0.5), CFrame.new(0, y - 0.6, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(150, 150, 160), nil, "Cyl")
end
function Props.loadingBar(c)
	local y = (c.CapY or c.Top) + 1.8
	c:Part("BarBack", Vector3.new(2.4, 0.4, 0.15), CFrame.new(0, y, 0), BLACK)
	c:Part("BarFill", Vector3.new(0.7, 0.3, 0.2), CFrame.new(-0.8, y, 0), GOO, Enum.Material.Neon)
end
function Props.floppyDisk(c)
	local h = headSide(c, 1)
	c:Part("Floppy", Vector3.new(1.1, 1.1, 0.12), CFrame.new(h + Vector3.new(0, 0, -0.3)), Color3.fromRGB(50, 90, 200))
	c:Part("FloppyLabel", Vector3.new(0.7, 0.4, 0.05), CFrame.new(h + Vector3.new(0, 0.25, -0.38)), WHITE)
end
function Props.fork(c)
	local h = headSide(c, 1)
	c:Rod("ForkHandle", h + Vector3.new(0, -0.8, 0), h + Vector3.new(0, 1.2, 0), 0.18, Color3.fromRGB(200, 200, 210), Enum.Material.Metal)
	for i = -1, 1 do
		c:Rod("Tine", h + Vector3.new(i * 0.18, 1.2, 0), h + Vector3.new(i * 0.18, 1.8, 0), 0.08, Color3.fromRGB(200, 200, 210), Enum.Material.Metal)
	end
end
function Props.headphones(c)
	local y = c.Top - 0.2
	c:Part("Band", Vector3.new(c.W * 0.9, 0.3, 0.4), CFrame.new(0, y + 0.3, 0.3), BLACK)
	for _, sx in { -1, 1 } do
		c:Part("Cup", Vector3.new(0.5, 1.1, 1.1), CFrame.new(sx * c.W * 0.48, c.Cy + 0.4, 0.2), Color3.fromRGB(255, 70, 140), nil, "Cyl")
	end
end
function Props.leafProp(c)
	c:E("Leaf", Vector3.new(0.3, 1.8, 0.9), headSide(c, 1) + Vector3.new(0, 0.4, -0.3), Color3.fromRGB(60, 170, 70))
end
function Props.wisp(c)
	local w = c:Part("Wisp", Vector3.one * 0.7, CFrame.new(1.8, c.Top + 0.6, 0), Color3.fromRGB(200, 255, 230), Enum.Material.Neon, "Ball")
	c:Particles(w, Color3.fromRGB(200, 255, 230), 8, 0.3, 0.5)
end
function Props.sprinkles(c)
	for i = 1, 12 do
		local a = i * 2.1
		local x, y = math.cos(a) * 0.9, 0.4 + math.sin(a) * 0.6
		c:Part("Sprinkle", Vector3.new(0.35, 0.1, 0.1), CFrame.new(x, c.Cy + y, c:Surf(x, y)) * CFrame.Angles(0, 0, a), RAINBOW[i % 6 + 1], Enum.Material.Neon)
	end
end
function Props.clock(c)
	local p = Vector3.new(0, (c.CapY or c.Top) + 2, 0)
	c:Part("Clock", Vector3.new(0.2, 1.5, 1.5), CFrame.new(p) * CFrame.Angles(0, math.rad(90), 0), WHITE, nil, "Cyl")
	c:Part("ClockHand", Vector3.new(0.1, 0.6, 0.06), CFrame.new(p + Vector3.new(0, 0.25, -0.12)), BLACK)
	c:Part("ClockHand", Vector3.new(0.45, 0.1, 0.06), CFrame.new(p + Vector3.new(0.2, 0, -0.12)), BLACK)
end
function Props.orange(c)
	c.TopProp = function(y)
		c:Part("Orange", Vector3.one * 1.1, CFrame.new(0, y + 0.5, 0), Color3.fromRGB(255, 150, 30), nil, "Ball")
	end
end
function Props.clawsUp(_c) end
function Props.sparks(c)
	c:Particles(c.Body, Color3.fromRGB(255, 240, 80), 10, 0.3, 4, "Sparks")
	local l = Instance.new("PointLight")
	l.Color = Color3.fromRGB(255, 240, 80)
	l.Range = 8
	l.Parent = c.Body
end
function Props.lightning(c)
	local y = (c.CapY or c.Top) + 1.2
	for i, p in { { 0, 0, 0.5 }, { 0.3, 0.6, -0.5 }, { 0.1, 1.2, 0.5 } } do
		c:Part("Bolt", Vector3.new(0.25, 0.8, 0.25), CFrame.new(1.4 + p[1], y + p[2], 0) * CFrame.Angles(0, 0, p[3]), Color3.fromRGB(255, 240, 60), Enum.Material.Neon)
	end
end
function Props.monocle(c)
	local x, y = c.W * 0.21, c.Cy + c.H * 0.12
	c:Keep(c:Part("Monocle", Vector3.new(0.1, 1.2, 1.2), CFrame.new(x, y, c:Surf(c.W * 0.21, c.H * 0.12) - 0.4) * CFrame.Angles(0, math.rad(90), 0), GOLD, Enum.Material.Glass, "Cyl")).Transparency = 0.5
end
function Props.camera(c)
	local h = headSide(c, 1)
	c:Part("Camera", Vector3.new(1.3, 0.9, 0.7), CFrame.new(h + Vector3.new(0, 0, -0.5)), BLACK)
	c:Part("Lens", Vector3.new(0.4, 0.6, 0.6), CFrame.new(h + Vector3.new(0, 0, -1)) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(80, 80, 100), Enum.Material.Glass, "Cyl")
end
function Props.screw(c)
	c.TopProp = function(y)
		c:Rod("Screw", Vector3.new(0.3, y - 0.3, 0), Vector3.new(0.5, y + 1.2, 0), 0.3, Color3.fromRGB(170, 170, 180), Enum.Material.Metal)
		c:Part("ScrewHead", Vector3.new(0.25, 0.9, 0.9), CFrame.new(0.5, y + 1.3, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(170, 170, 180), Enum.Material.Metal, "Cyl")
	end
end
function Props.tinfoil(c)
	c.TopProp = function(y)
		for i = 0, 3 do
			local w = 1.6 - i * 0.38
			c:Part("Tinfoil", Vector3.new(0.45, w, w), CFrame.new(0, y + 0.3 + i * 0.4, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(210, 210, 220), Enum.Material.Foil, "Cyl")
		end
	end
end
function Props.goldChain(c)
	for i = 1, 10 do
		local a = i / 10 * math.pi
		c:Keep(c:Part("Chain", Vector3.one * 0.35, CFrame.new(math.cos(a) * c.W * 0.32, c.Cy - c.H * 0.32 - math.sin(a) * 0.4, c:Surf(0, -c.H * 0.3) - 0.1), GOLD, Enum.Material.Neon, "Ball"))
	end
end
function Props.scarf(c)
	c:Part("Scarf", Vector3.new(0.6, c.W * 0.95, c.D * 0.95), CFrame.new(0, c.Cy - c.H * 0.2, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(60, 230, 255), Enum.Material.Neon, "Cyl")
	c:Part("ScarfEnd", Vector3.new(0.5, 1.2, 0.2), CFrame.new(0.6, c.Cy - c.H * 0.4, c:Surf(0.6, -0.4) - 0.15), Color3.fromRGB(60, 230, 255), Enum.Material.Neon)
end
local function crownAt(c, y, s)
	for i = 1, 6 do
		local a = i / 6 * math.pi * 2
		c:Keep(c:Part("Crown", Vector3.new(0.3, 0.7, 0.3) * s, CFrame.new(math.cos(a) * 0.55 * s, y + 0.35 * s, math.sin(a) * 0.55 * s), GOLD, Enum.Material.Neon))
	end
	c:Keep(c:Part("CrownBand", Vector3.new(0.3 * s, 1.3 * s, 1.3 * s), CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.rad(90)), GOLD, Enum.Material.Neon, "Cyl"))
end
function Props.crown(c)
	c.TopProp = function(y)
		crownAt(c, y + 0.1, 1.2)
	end
end
function Props.headset(c)
	Props.headphones(c)
	c:Rod("Mic", Vector3.new(c.W * 0.48, c.Cy + 0.2, 0), Vector3.new(0.4, c.Cy - 0.4, c:Surf(0.4, -0.4) - 0.3), 0.12, BLACK)
end
function Props.siren(c)
	c.TopProp = function(y)
		local s = c:Part("Siren", Vector3.one * 1, CFrame.new(0.9, y + 0.2, 0), Color3.fromRGB(255, 40, 40), Enum.Material.Neon, "Ball")
		local l = Instance.new("PointLight")
		l.Color = Color3.fromRGB(255, 40, 40)
		l.Range = 10
		l.Parent = s
	end
end
function Props.partyHat(c)
	c.TopProp = function(y)
		for i = 0, 3 do
			local w = 1.3 - i * 0.3
			c:Part("PartyHat", Vector3.new(0.45, w, w), CFrame.new(1, y + i * 0.4, 0) * CFrame.Angles(0, 0, math.rad(90)), RAINBOW[i + 1], nil, "Cyl")
		end
	end
end
function Props.seahorse(c)
	local tip = c.TrunkTip or Vector3.new(0, c.Cy, -c.D / 2)
	c:E("Seahorse", Vector3.new(0.4, 0.8, 0.4), tip + Vector3.new(0, 0.5, 0), Color3.fromRGB(255, 150, 60))
end
function Props.zipper(c)
	c.TopProp = function(y, capW)
		c:Keep(c:Part("Zipper", Vector3.new(capW * 0.9, 0.15, 0.25), CFrame.new(0, y - 0.05, -0.1), Color3.fromRGB(200, 200, 210), Enum.Material.Metal))
		c:Keep(c:Part("ZipPull", Vector3.new(0.3, 0.5, 0.15), CFrame.new(capW * 0.45, y - 0.3, -0.2), Color3.fromRGB(200, 200, 210), Enum.Material.Metal))
	end
end
function Props.heartBreath(c)
	local e = c:Particles(c.Body, Color3.fromRGB(255, 90, 170), 6, 0.5, 3, "Hearts")
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.EmissionDirection = Enum.NormalId.Front
	e.SpreadAngle = Vector2.new(20, 20)
end
function Props.rainbowTrail(c)
	local seq = {}
	for i, col in RAINBOW do
		table.insert(seq, ColorSequenceKeypoint.new((i - 1) / (#RAINBOW - 1), col))
	end
	c:Particles(c.Body, ColorSequence.new(seq), 14, 0.5, 1, "RainbowTrail").EmissionDirection = Enum.NormalId.Back
end
function Props.captainHat(c)
	c.TopProp = function(y)
		c:Part("CaptainHat", Vector3.new(0.6, 1.8, 1.8), CFrame.new(1.2, y, 0.2) * CFrame.Angles(0, 0, math.rad(80)), WHITE, nil, "Cyl")
		c:Part("CaptainBrim", Vector3.new(0.2, 1.3, 1.3), CFrame.new(1.1, y - 0.3, -0.4) * CFrame.Angles(0, 0, math.rad(80)), BLACK, nil, "Cyl")
	end
end
function Props.fire(c)
	local f = Instance.new("Fire")
	f.Size = 4
	f.Heat = 6
	f.Parent = c.Body
end
function Props.iceBlock(c)
	c:Part("IceBlock", Vector3.new(1.4, 1.4, 1.4), CFrame.new(c.W * 0.5 + 1, 0.7, 0) * CFrame.Angles(0, 0.4, 0), Color3.fromRGB(180, 230, 255), Enum.Material.Ice).Transparency = 0.3
end
function Props.cape(c)
	c:Part("Cape", Vector3.new(c.W * 0.9, c.H * 0.9, 0.2), CFrame.new(0, c.Cy - 0.1, c.D * 0.48) * CFrame.Angles(0.15, 0, 0), Color3.fromRGB(200, 30, 60))
end
function Props.scepter(c)
	local h = headSide(c, 1)
	c:Rod("Scepter", h + Vector3.new(0, -1.2, 0), h + Vector3.new(0, 1.4, 0), 0.25, GOLD, Enum.Material.Neon)
	c:Part("ScepterGem", Vector3.one * 0.7, CFrame.new(h + Vector3.new(0, 1.7, 0)), BRAIN, Enum.Material.Neon, "Ball")
end
function Props.lawn(c)
	c:Part("Lawn", Vector3.new(2, 0.3, 2), CFrame.new(-c.W * 0.5 - 1.6, 0.15, 0), Color3.fromRGB(70, 190, 60), Enum.Material.Grass)
	c:Text(c.Body, "NO!", Color3.fromRGB(255, 80, 80), c.H * 0.6, 34)
end
function Props.briefcase(c)
	local h = headSide(c, 1) + Vector3.new(0, -0.9, 0)
	c:Part("Briefcase", Vector3.new(0.5, 1, 1.4), CFrame.new(h), Color3.fromRGB(60, 35, 20))
	c:Part("Handle", Vector3.new(0.15, 0.25, 0.6), CFrame.new(h + Vector3.new(0, 0.6, 0)), BLACK)
end
function Props.laurel(c)
	c.TopProp = function(y, capW)
		for i = 1, 10 do
			local a = i / 10 * math.pi * 2
			c:Keep(c:E("Laurel", Vector3.new(0.5, 0.2, 0.3), Vector3.new(math.cos(a) * capW * 0.55, y - 0.4, math.sin(a) * capW * 0.55), Color3.fromRGB(90, 190, 70)))
		end
	end
end
function Props.toga(c)
	c:Part("Toga", Vector3.new(0.6, c.H * 1.05, 0.3), CFrame.new(0, c.Cy, c:Surf(0, 0) - 0.05) * CFrame.Angles(0, 0, 0.6), WHITE)
end
function Props.rainbowAura(c)
	local seq = {}
	for i, col in RAINBOW do
		table.insert(seq, ColorSequenceKeypoint.new((i - 1) / (#RAINBOW - 1), col))
	end
	c:Particles(c.Body, ColorSequence.new(seq), 25, 0.8, 3, "RainbowAura")
end
function Props.halo(c)
	c.HaloProp = true
end
function Props.gooPuddle(c)
	c:Part("GooPuddle", Vector3.new(0.2, c.W * 1.6, c.W * 1.6), CFrame.new(0, 0.1, 0) * CFrame.Angles(0, 0, math.rad(90)), GOO, Enum.Material.Neon, "Cyl")
end
function Props.flies(c)
	local e = c:Particles(c.Body, BLACK, 8, 0.25, 2, "Flies")
	e.LightEmission = 0
	e.SpreadAngle = Vector2.new(180, 180)
end
function Props.floatingEyes(c)
	for i = 1, 3 do
		local a = i / 3 * math.pi * 2
		local p = Vector3.new(math.cos(a) * 2.2, c.Cy + 1.2 + i * 0.3, math.sin(a) * 2.2)
		c:Keep(c:Part("FloatingEye", Vector3.one * 0.8, CFrame.new(p), WHITE, nil, "Ball"))
		c:Keep(c:Part("FloatingPupil", Vector3.one * 0.4, CFrame.new(p + Vector3.new(0, 0, -0.3)), BLACK, nil, "Ball"))
	end
end
function Props.hearts(c)
	local e = c:Particles(c.Body, Color3.fromRGB(255, 120, 190), 6, 0.5, 0.5, "FallingHearts")
	e.Acceleration = Vector3.new(0, -3, 0)
end

local function buildFace(c)
	local f = c.Flags
	local eyeY = c.Cy + c.H * 0.12
	local s = (f.wideEyes or f.scaredFace) and 1.15 or 0.9
	local eyes
	if f.longNeck then
		eyes = {}
	elseif f.cyclops then
		eyes = { { 0, eyeY, 1.7 } }
	elseif f.manyEyes then
		eyes = { { -c.W * 0.25, eyeY, 0.8 }, { c.W * 0.25, eyeY, 0.8 }, { 0, eyeY + c.H * 0.2, 0.9 }, { -c.W * 0.12, eyeY - c.H * 0.17, 0.6 }, { c.W * 0.12, eyeY - c.H * 0.17, 0.6 } }
	elseif f.topEyes then
		eyes = { { -c.W * 0.25, c.Top - 0.1, 1 }, { c.W * 0.25, c.Top - 0.1, 1 } }
	else
		eyes = { { -c.W * 0.21, eyeY, s }, { c.W * 0.21, eyeY, s } }
	end
	for _, e in eyes do
		local x, y, es = e[1], e[2], e[3]
		local z = c:Surf(x, y - c.Cy)
		if f.topEyes then
			z = -c.D * 0.25
			c:Part("EyeBump", Vector3.one * es * 1.3, CFrame.new(x, y - 0.25, z + 0.1), c.Color, nil, "Ball")
		end
		if f.pandaPatches then
			c:E("Patch", Vector3.new(es * 1.4, es * 1.5, es * 0.5), Vector3.new(x, y, z + 0.1), BLACK)
		end
		c:Keep(c:E("Eye", Vector3.new(es, es * 1.1, es * 0.6), Vector3.new(x, y, z), WHITE))
		c:Keep(c:E("Pupil", Vector3.new(es * 0.55, es * 0.62, es * 0.3), Vector3.new(x, y - es * 0.05, z - es * 0.22), BLACK))
		c:Keep(c:E("Shine", Vector3.one * es * 0.22, Vector3.new(x + es * 0.12, y + es * 0.15, z - es * 0.36), WHITE, Enum.Material.Neon))
		if f.sleepyEyes or f.calmEyes then
			c:E("Lid", Vector3.new(es * 1.1, es * 0.62, es * 0.66), Vector3.new(x, y + es * 0.3, z - 0.03), c.Color)
		end
		if f.eyeBags then
			c:E("EyeBag", Vector3.new(es * 0.9, es * 0.25, es * 0.3), Vector3.new(x, y - es * 0.62, z - 0.05), Color3.fromRGB(110, 80, 140))
		end
	end
	if not f.longNeck then
		for _, sx in { -1, 1 } do
			local bx, by = sx * c.W * 0.33, -c.H * 0.04
			c:Keep(c:E("Blush", Vector3.new(0.7, 0.35, 0.12), Vector3.new(bx, c.Cy + by, c:Surf(bx, by) - 0.03), BLUSH))
		end
		local my = -c.H * 0.14
		if f.scaredFace then
			c:Keep(c:E("Mouth", Vector3.new(0.5, 0.65, 0.15), Vector3.new(0, c.Cy + my, c:Surf(0, my) - 0.03), BLACK))
		else
			c:Keep(c:E("Mouth", Vector3.new(0.75, 0.22, 0.15), Vector3.new(0, c.Cy + my, c:Surf(0, my) - 0.03), BLACK))
		end
	end
end

local function buildBrainCap(c)
	local capS = c.CapScale or 1
	local capW, capH, capD = c.W * 0.62 * capS, math.max(0.9, c.H * 0.3) * capS, c.D * 0.55 * capS
	if c.Def.Body == "Long" then
		capD = c.W * 0.6 * capS
	end
	local baseY = c.CapY or (c.Top - c.H * 0.06)
	local zOff = c.Def.Body == "Long" and -c.D * 0.18 or 0
	local cy = baseY + capH * 0.3
	local cap = c:E("BrainCap", Vector3.new(capW, capH, capD), Vector3.new(0, cy, zOff), BRAIN)
	cap:SetAttribute("Cap", true)
	for i = -1, 1 do
		local fold = c:E("BrainCapFold", Vector3.new(0.18, capH * 0.35, capD * 0.88), Vector3.new(i * capW * 0.24, cy + capH * 0.36 - math.abs(i) * capH * 0.12, zOff), BRAIN_FOLD)
		fold:SetAttribute("Cap", true)
	end
	if c.TopProp then
		c.TopProp(cy + capH * 0.5, capW)
	end
	c.CapTop = cy + capH * 0.5
end

function BrainrotModelKit.BuildBase(def)
	local size = BODY_SIZES[def.Body] or BODY_SIZES.Blob
	local m = Instance.new("Model")
	m.Name = def.Name
	local c = setmetatable({ Model = m, Def = def, W = size.X, H = size.Y, D = size.Z, Color = def.Color, Belly = def.Belly, Lift = 0, Flags = {} }, Ctx)
	for _, f in def.Features do
		c.Flags[f] = true
		if Pre[f] then
			Pre[f](c)
		end
	end
	c.Cy = 0.5 + c.Lift + c.H / 2
	c.Top = c.Cy + c.H / 2
	local bodyCf = CFrame.new(0, c.Cy, 0)
	local body
	if def.Body == "Block" then
		body = c:Part("Body", size, bodyCf, c.Color)
	elseif def.Body == "Wedge" then
		body = c:Part("Body", size, bodyCf * CFrame.Angles(0, math.pi, 0), c.Color, nil, "Wedge")
		c.Top = c.Cy + c.H * 0.35
	else
		body = c:Part("Body", size, bodyCf, c.Color, nil, "Ell")
	end
	c.Body = body
	m.PrimaryPart = body
	if def.Body ~= "Wedge" and not c.Flags.brainBody then
		local by = -c.H * 0.2
		c:E("Belly", Vector3.new(c.W * 0.6, c.H * 0.48, 0.5), Vector3.new(0, c.Cy + by, c:Surf(0, by) + 0.12), c.Belly)
	end
	if not c.NoFeet then
		for _, sx in { -1, 1 } do
			c:E("Foot", Vector3.new(0.95, 0.5, 1.2), Vector3.new(sx * c.W * 0.25, 0.25, -c.D * 0.18), c.Flags.orangeFeet and Color3.fromRGB(255, 150, 30) or darker(c.Color, 0.1))
		end
	end
	for _, f in def.Features do
		Features[f](c)
	end
	for _, p in def.Props do
		Props[p](c)
	end
	buildFace(c)
	buildBrainCap(c)
	if c.HaloProp then
		for i = 1, 12 do
			local a = i / 12 * math.pi * 2
			c:Keep(c:Part("Halo", Vector3.one * 0.35, CFrame.new(math.cos(a) * 1.1, c.CapTop + 0.9, math.sin(a) * 1.1), GOLD, Enum.Material.Neon, "Ball"))
		end
	end
	body.PivotOffset = body.CFrame:Inverse()
	return m, c
end

local function weldAll(m)
	local body = m.PrimaryPart
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") and p ~= body and not p:FindFirstChildOfClass("WeldConstraint") then
			local w = Instance.new("WeldConstraint")
			w.Part0 = body
			w.Part1 = p
			w.Parent = p
			p.Anchored = false
		end
	end
end

function BrainrotModelKit.AddRarityFx(m, def)
	local rarity = RarityConfig.ByName[def.Rarity]
	local body = m.PrimaryPart
	local h = m:GetExtentsSize().Y
	local function part(name, size, cf, color, shape, transparency)
		local p = Instance.new("Part")
		p.Name = name
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.Massless = true
		p.Material = Enum.Material.Neon
		p.Size = size
		p.CFrame = cf
		p.Color = color
		p.Transparency = transparency or 0
		if shape then
			p.Shape = shape
		end
		p.Parent = m
		return p
	end
	local pivot = m:GetPivot()
	if rarity.Index >= 3 then
		local l = Instance.new("PointLight")
		l.Color = rarity.Color
		l.Range = 6 + rarity.Index * 2
		l.Brightness = 1.5
		l.Parent = body
	end
	if rarity.Index >= 4 then
		local e = Instance.new("ParticleEmitter")
		e.Name = "RaritySparkles"
		e.Color = ColorSequence.new(rarity.Color)
		e.LightEmission = 1
		e.Rate = 4 + rarity.Index
		e.Lifetime = NumberRange.new(1, 1.5)
		e.Speed = NumberRange.new(1, 2)
		e.SpreadAngle = Vector2.new(180, 180)
		e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
		e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		e.Parent = body
	end
	if rarity.Index >= 5 then
		local w = m:GetExtentsSize().X * 1.1
		part("AuraRing", Vector3.new(0.2, w, w), pivot * CFrame.new(0, 0.15, 0) * CFrame.Angles(0, 0, math.rad(90)), rarity.Color, Enum.PartType.Cylinder, 0.45)
	end
	if rarity.Index >= 6 then
		local beamColor = rarity.Index == 8 and GOO or rarity.Color
		part("LightBeam", Vector3.new(26, 2.2, 2.2), pivot * CFrame.new(0, 13, 0) * CFrame.Angles(0, 0, math.rad(90)), beamColor, Enum.PartType.Cylinder, 0.82)
	end
	if rarity.Index == 7 then
		for i = 1, 14 do
			local a = i / 14 * math.pi * 2
			part("GodHalo", Vector3.one * 0.5, pivot * CFrame.new(math.cos(a) * 1.6, h + 0.6, math.sin(a) * 1.6), GOLD, Enum.PartType.Ball)
		end
	end
	if rarity.Index == 8 then
		for i = 1, 6 do
			local a = i / 6 * math.pi * 2
			part("RotDrip", Vector3.new(0.4, 1.4, 0.4), pivot * CFrame.new(math.cos(a) * 1.6, 1.2, math.sin(a) * 1.6), GOO)
		end
		local e = Instance.new("ParticleEmitter")
		e.Name = "RotFlies"
		e.Color = ColorSequence.new(BLACK)
		e.Rate = 10
		e.Lifetime = NumberRange.new(1, 2)
		e.Speed = NumberRange.new(2, 4)
		e.SpreadAngle = Vector2.new(180, 180)
		e.Size = NumberSequence.new(0.2)
		e.Parent = body
	end
end

function BrainrotModelKit.ApplyMutation(m, mutName)
	local mut = MutationConfig.ByName[mutName]
	if not mut then
		return
	end
	m:SetAttribute("Mutation", mutName)
	local body = m.PrimaryPart
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") and not p:GetAttribute("Keep") and p.Material ~= Enum.Material.Neon then
			local isCap = p:GetAttribute("Cap")
			if mutName == "Rotten" then
				p.Color = p.Color:Lerp(GOO, 0.45)
			elseif mutName == "Golden" then
				p.Color = GOLD:Lerp(p.Color, 0.15)
				p.Material = Enum.Material.Metal
				p.Reflectance = 0.25
			elseif mutName == "Rizzed" then
				p.Color = p.Color:Lerp(Color3.fromRGB(255, 120, 200), 0.3)
			elseif mutName == "Galaxy Brain" then
				p.Color = isCap and Color3.fromRGB(140, 70, 255) or p.Color:Lerp(Color3.fromRGB(60, 30, 140), 0.55)
				if isCap then
					p.Material = Enum.Material.Neon
				end
			elseif mutName == "Brain Freeze" then
				p.Color = p.Color:Lerp(Color3.fromRGB(170, 230, 255), 0.6)
				p.Material = Enum.Material.Ice
			elseif mutName == "Sigma" then
				p.Color = isCap and GOLD or Color3.fromRGB(30, 30, 35):Lerp(p.Color, 0.15)
			elseif mutName == "Ohio" then
				p.Color = Color3.new(1 - p.Color.R, 1 - p.Color.G, 1 - p.Color.B)
			elseif mutName == "Max Aura" then
				p.Color = p.Color:Lerp(WHITE, 0.3)
			end
		end
	end
	local function fx(color, rate, size, name)
		local e = Instance.new("ParticleEmitter")
		e.Name = name
		e.Color = typeof(color) == "ColorSequence" and color or ColorSequence.new(color)
		e.LightEmission = 1
		e.Rate = rate
		e.Lifetime = NumberRange.new(1, 2)
		e.Speed = NumberRange.new(1, 3)
		e.SpreadAngle = Vector2.new(180, 180)
		e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, 0) })
		e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		e.Parent = body
		return e
	end
	if mutName == "Rotten" then
		fx(GOO, 8, 0.4, "GooDrips").Acceleration = Vector3.new(0, -12, 0)
	elseif mutName == "Golden" then
		fx(GOLD, 6, 0.4, "GoldShine")
	elseif mutName == "Rizzed" then
		fx(Color3.fromRGB(255, 120, 200), 12, 0.5, "RizzSparkles")
	elseif mutName == "Galaxy Brain" then
		fx(WHITE, 14, 0.3, "Stars")
	elseif mutName == "Brain Freeze" then
		fx(Color3.fromRGB(200, 240, 255), 10, 0.4, "Frost")
	elseif mutName == "Sigma" then
		fx(GOLD, 5, 0.5, "SigmaGlint")
	elseif mutName == "Ohio" then
		m:SetAttribute("Jitter", true)
		fx(Color3.fromRGB(255, 60, 60), 8, 0.4, "OhioGlitch")
	elseif mutName == "Max Aura" then
		local seq = {}
		for i, col in RAINBOW do
			table.insert(seq, ColorSequenceKeypoint.new((i - 1) / (#RAINBOW - 1), col))
		end
		local e = fx(ColorSequence.new(seq), 30, 1.2, "MaxAura")
		e.Speed = NumberRange.new(4, 6)
	end
end

function BrainrotModelKit.Income(entry)
	local def = BrainrotCatalog.Get(entry.Id)
	return def.Income * MutationConfig.Mult(entry.Mut) * (1 + 0.25 * ((entry.Lv or 1) - 1))
end

function BrainrotModelKit.AttachTag(m, entry, footer)
	local def = BrainrotCatalog.Get(entry.Id)
	local rarity = RarityConfig.ByName[def.Rarity]
	local old = m.PrimaryPart:FindFirstChild("NameTag")
	if old then
		old:Destroy()
	end
	local bb = Instance.new("BillboardGui")
	bb.Name = "NameTag"
	bb.Size = UDim2.fromScale(9, 4)
	bb.StudsOffsetWorldSpace = Vector3.new(0, m:GetExtentsSize().Y * 0.5 + 2.4, 0)
	bb.MaxDistance = 70
	bb.LightInfluence = 0
	local mut = entry.Mut and MutationConfig.ByName[entry.Mut]
	local header = Instance.new("Frame")
	header.Size = UDim2.fromScale(0.86, 0.26)
	header.Position = UDim2.fromScale(0.07, 0)
	header.BackgroundColor3 = rarity.Color
	header.Parent = bb
	Instance.new("UICorner", header).CornerRadius = UDim.new(0.4, 0)
	local income = footer or ("+" .. NumberFormat.Cells(BrainrotModelKit.Income(entry)) .. "/s" .. ((entry.Lv or 1) > 1 and (" · Lv " .. entry.Lv) or ""))
	local lines = {
		{ header, string.upper(def.Rarity) .. (mut and (" · " .. string.upper(mut.Name)) or ""), Color3.fromRGB(25, 8, 30), 0, 1, 1 },
		{ bb, def.Name, WHITE, 0.27, 0.38, 0 },
		{ bb, income, Color3.fromRGB(150, 255, 110), 0.65, 0.35, 0 },
	}
	for _, line in lines do
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, line[5])
		t.Position = UDim2.fromScale(0, line[4])
		t.BackgroundTransparency = 1
		t.Text = line[2]
		t.TextColor3 = line[3]
		t.TextScaled = true
		t.Font = Enum.Font.FredokaOne
		t.TextStrokeTransparency = line[6]
		t.Parent = line[1]
	end
	bb.Parent = m.PrimaryPart
	return bb
end

-- entry = { Id, Mut, Lv }. opts.scale multiplies the rarity scale; opts.tag = false skips the name tag.
function BrainrotModelKit.Build(entry, opts)
	opts = opts or {}
	local def = BrainrotCatalog.Get(entry.Id)
	local rarity = RarityConfig.ByName[def.Rarity]
	local m = BrainrotModelKit.BuildBase(def)
	weldAll(m)
	m:ScaleTo(rarity.Scale * (opts.scale or 1) * 1.3)
	if opts.fx ~= false then
		BrainrotModelKit.AddRarityFx(m, def)
		weldAll(m)
	end
	if entry.Mut then
		BrainrotModelKit.ApplyMutation(m, entry.Mut)
	end
	m:SetAttribute("BrainrotId", entry.Id)
	if opts.tag ~= false then
		BrainrotModelKit.AttachTag(m, entry, opts.footer)
	end
	return m
end

function BrainrotModelKit.MakeGlider(m)
	local body = m.PrimaryPart
	local att = Instance.new("Attachment")
	att.Name = "GlideAttachment"
	att.CFrame = body.PivotOffset
	att.Parent = body
	local ap = Instance.new("AlignPosition")
	ap.Mode = Enum.PositionAlignmentMode.OneAttachment
	ap.Attachment0 = att
	ap.RigidityEnabled = true
	ap.Position = m:GetPivot().Position
	ap.Parent = body
	local ao = Instance.new("AlignOrientation")
	ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	ao.Attachment0 = att
	ao.RigidityEnabled = true
	ao.CFrame = m:GetPivot()
	ao.Parent = body
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = false
			p.CanCollide = false
		end
	end
	return function(cf: CFrame)
		ap.Position = cf.Position
		ao.CFrame = cf
	end
end

return BrainrotModelKit
