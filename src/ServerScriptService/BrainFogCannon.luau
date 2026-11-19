local Debris = game:GetService("Debris")
local WorldBuilder = require(script.Parent.WorldBuilder)
local DataService = require(script.Parent.DataService)
local LobeService = require(script.Parent.LobeService)
local GameSignals = require(script.Parent.GameSignals)
local PixieRaid = require(script.Parent.ProductivityPixieRaid)
local HudNotify = require(script.Parent.HudNotify)

local BrainFogCannon = { Cannons = {} }

local FOG = Color3.fromRGB(200, 170, 255)
local CANNON_SHEET = {
	{ Name = "Base", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.2, 3.2, 3.2), Offset = CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(110, 110, 125) },
	{ Name = "Ball", Shape = Enum.PartType.Ball, Size = Vector3.one * 2.6, Offset = CFrame.new(0, 2.4, 0), Color = FOG },
	{ Name = "Barrel", Shape = Enum.PartType.Cylinder, Size = Vector3.new(3.2, 1, 1), Offset = CFrame.new(0, 2.9, -1.6) * CFrame.Angles(0, math.rad(90), math.rad(20)), Color = Color3.fromRGB(90, 90, 105) },
	{ Name = "Muzzle", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.9, Offset = CFrame.new(0, 3.4, -3.1), Color = FOG, Neon = true },
}

function BrainFogCannon.Level(player: Player)
	return math.clamp(1 + math.floor(DataService.Get(player).Upgrades.Defense / 2.5), 1, 5)
end

local function build(at: CFrame)
	local m = Instance.new("Model")
	m.Name = "BrainFogCannon"
	for _, row in CANNON_SHEET do
		local p = WorldBuilder.Part(m, { Name = row.Name, Shape = row.Shape, Size = row.Size, CFrame = at * row.Offset, Color = row.Color, Material = row.Neon and Enum.Material.Neon or Enum.Material.SmoothPlastic })
		if row.Name == "Base" then
			m.PrimaryPart = p
		end
	end
	m.PrimaryPart.PivotOffset = m.PrimaryPart.CFrame:ToObjectSpace(at)
	return m
end

local function refresh(lobe)
	for _, c in BrainFogCannon.Cannons[lobe.Index] or {} do
		c.Model:Destroy()
	end
	BrainFogCannon.Cannons[lobe.Index] = {}
	if not lobe.Owner then
		return
	end
	for i, slot in WorldBuilder.Layout.CannonSlots do
		if i == 1 or lobe.Level >= 4 then
			local at = lobe.CF * CFrame.new(slot + Vector3.new(0, 0.3, 0))
			local m = build(at)
			m.Parent = lobe.Model
			table.insert(BrainFogCannon.Cannons[lobe.Index], { Model = m, Base = at, Ready = 0 })
		end
	end
end

local function fire(cannon, pixie, owner, level)
	local target = pixie.Model:GetPivot().Position
	local base = cannon.Base
	cannon.Model:PivotTo(CFrame.lookAt(base.Position, Vector3.new(target.X, base.Position.Y, target.Z)))
	if math.random() > 0.4 + 0.12 * level then
		HudNotify.Popup(nil, "MISSED! NPC AIM", Color3.fromRGB(200, 200, 200), target + Vector3.new(0, 3, 0))
		return
	end
	local muzzle = cannon.Model.Muzzle.Position
	local beam = WorldBuilder.Segment(workspace, muzzle, target, 0.8, FOG, Enum.Material.Neon, "FogBeam")
	beam.Transparency = 0.4
	beam.CanQuery = false
	Debris:AddItem(beam, 0.35)
	local cloud = WorldBuilder.Part(workspace, { Name = "BrainFogCloud", Size = Vector3.one, Position = target, Transparency = 1, CanCollide = false, CanQuery = false })
	local e = WorldBuilder.Sparkles(cloud, Color3.fromRGB(215, 205, 235), 0, "Fog")
	e.LightEmission = 0
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 6) })
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
	e.Lifetime = NumberRange.new(1.5, 2.5)
	e.Speed = NumberRange.new(1, 3)
	e:Emit(25)
	Debris:AddItem(cloud, 3)
	PixieRaid.Defeat(pixie, owner, "fog")
end

function BrainFogCannon.Start()
	GameSignals.On("LobeAssigned", function(_, lobe)
		refresh(lobe)
	end)
	GameSignals.On("LobeUpgraded", function(_, lobe)
		refresh(lobe)
	end)
	GameSignals.On("LobeReleased", refresh)
	task.spawn(function()
		while true do
			task.wait(0.4)
			for _, lobe in LobeService.Lobes do
				local owner = lobe.Owner
				if owner and DataService.Get(owner) then
					local level = BrainFogCannon.Level(owner)
					local range, cooldown = 28 + 6 * level, 4.5 - 0.5 * level
					for _, cannon in BrainFogCannon.Cannons[lobe.Index] or {} do
						if cannon.Ready <= os.clock() then
							local best, bestD
							for _, pixie in PixieRaid.Pixies do
								local d = (pixie.Model:GetPivot().Position - cannon.Base.Position).Magnitude
								if d <= range and pixie.Lobe == lobe and pixie.Loot and (not bestD or d < bestD) then
									best, bestD = pixie, d
								end
							end
							if best then
								cannon.Ready = os.clock() + cooldown
								fire(cannon, best, owner, level)
							end
						end
					end
				end
			end
		end
	end)
end

return BrainFogCannon
