local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HudNotify = require(script.Parent.HudNotify)

local AwakeRemCycle = { Phase = "Awake" }

local AWAKE_SECONDS, REM_SECONDS, FADE = 150, 90, 8

local PHASES = {
	Awake = { ClockTime = 14, Ambient = Color3.fromRGB(110, 70, 110), OutdoorAmbient = Color3.fromRGB(160, 110, 160), Brightness = 2.2 },
	REM = { ClockTime = 0.5, Ambient = Color3.fromRGB(140, 70, 170), OutdoorAmbient = Color3.fromRGB(150, 80, 180), Brightness = 1.2 },
}

local function setNeonGlow(on: boolean)
	for _, d in workspace.BrainWorld:GetDescendants() do
		if d:IsA("PointLight") and d.Parent:IsA("BasePart") and d.Parent.Material == Enum.Material.Neon then
			d.Brightness = on and 5 or 2.5
		end
	end
	local spray = workspace.BrainWorld.BrainStemPlaza.GooFountain.MiniBrain:FindFirstChild("GooSpray")
	if spray then
		spray.Rate = on and 90 or 40
	end
end

function AwakeRemCycle.Enter(phase: string)
	AwakeRemCycle.Phase = phase
	local goal = PHASES[phase]
	TweenService:Create(Lighting, TweenInfo.new(FADE), goal):Play()
	setNeonGlow(phase == "REM")
	HudNotify.Feed(nil, phase == "REM" and "🌙 REM SLEEP: the neurons and the goo glow. Memes dream harder." or "☀️ AWAKE: the kid is scrolling again.")
end

function AwakeRemCycle.Start()
	task.spawn(function()
		while true do
			task.wait(AWAKE_SECONDS)
			AwakeRemCycle.Enter("REM")
			task.wait(REM_SECONDS)
			AwakeRemCycle.Enter("Awake")
		end
	end)
end

return AwakeRemCycle
