local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local MutationConfig = require(RS.MutationConfig)
local WorldBuilder = require(script.Parent.WorldBuilder)
local SynapseBelt = require(script.Parent.SynapseBelt)

local MutationService = {}

local rng = Random.new()

function MutationService.Roll(luck: number, forced: boolean?)
	return MutationConfig.Roll(rng, luck, forced)
end

function MutationService.MutateEntry(entry, luck: number)
	entry.Mut = MutationConfig.Roll(rng, luck, true)
	return entry.Mut
end

local function skyParticles(name, color, rate, size)
	local sky = WorldBuilder.Part(workspace, { Name = name, Size = Vector3.new(380, 1, 380), Position = Vector3.new(0, 90, 0), Transparency = 1, CanCollide = false, CanQuery = false })
	local e = WorldBuilder.Sparkles(sky, color, rate, name .. "Fx")
	e.Size = NumberSequence.new(size)
	e.Lifetime = NumberRange.new(6, 9)
	e.Speed = NumberRange.new(8, 12)
	e.EmissionDirection = Enum.NormalId.Bottom
	e.SpreadAngle = Vector2.new(20, 20)
	return sky
end
MutationService.SkyParticles = skyParticles

function MutationService.BrainFreeze(duration: number)
	SynapseBelt.ForceMutation = true
	SynapseBelt.MutateAll(SynapseBelt.Lines.Main)
	local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	local tint = cc.TintColor
	TweenService:Create(cc, TweenInfo.new(1.5), { TintColor = Color3.fromRGB(190, 225, 255) }):Play()
	local snow = skyParticles("IceCrystals", Color3.fromRGB(210, 240, 255), 120, 0.8)
	task.wait(duration)
	SynapseBelt.ForceMutation = false
	TweenService:Create(cc, TweenInfo.new(1.5), { TintColor = tint }):Play()
	snow:Destroy()
end

function MutationService.Start() end

return MutationService
