local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local BrainrotCatalog = require(RS.BrainrotCatalog)
local RarityConfig = require(RS.RarityConfig)
local MutationConfig = require(RS.MutationConfig)
local LobeService = require(script.Parent.LobeService)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)
local MostRottedBoard = require(script.Parent.MostRottedBoard)

local NpcKids = { Rigs = {} }

local NAMES = { "ScrollGoblin", "BrainFogBen", "3AM_Ava", "NoSleepNoah", "OhioOllie", "DopamineDan", "RizzlessRiley", "NeverTouchedGrass" }
local HOODIES = { Color3.fromRGB(255, 120, 180), Color3.fromRGB(90, 200, 255), Color3.fromRGB(140, 255, 100), Color3.fromRGB(255, 200, 60), Color3.fromRGB(170, 110, 255), Color3.fromRGB(255, 110, 90) }
local SKIN = { Color3.fromRGB(255, 220, 190), Color3.fromRGB(210, 160, 120), Color3.fromRGB(140, 95, 65) }
local SLANG = { "SIGMA!", "RIZZED!", "+100 AURA", "NPC MOMENT", "BRAIN FOG...", "OHIO!", "-1000 AURA", "DOPAMINE!", "LOW BATTERY" }

local rng = Random.new(3)

local function buildKid(name, at: CFrame)
	local desc = Instance.new("HumanoidDescription")
	local hoodie = HOODIES[rng:NextInteger(1, #HOODIES)]
	local skin = SKIN[rng:NextInteger(1, #SKIN)]
	desc.HeadColor = skin
	desc.TorsoColor = hoodie
	desc.LeftArmColor = hoodie
	desc.RightArmColor = hoodie
	desc.LeftLegColor = Color3.fromRGB(40, 40, 60)
	desc.RightLegColor = Color3.fromRGB(40, 40, 60)
	local ok, rig = pcall(function()
		return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
	end)
	if not ok then
		return nil
	end
	rig.Name = name
	rig.Humanoid.DisplayName = "📱 " .. name
	rig.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	rig.HumanoidRootPart.Anchored = true
	rig:PivotTo(at)
	local hand = rig:FindFirstChild("RightHand")
	if hand then
		local phone = Instance.new("Part")
		phone.Name = "Phone"
		phone.Size = Vector3.new(0.5, 0.9, 0.1)
		phone.Color = Color3.fromRGB(20, 20, 30)
		phone.CanCollide = false
		phone.Massless = true
		phone.CFrame = hand.CFrame * CFrame.new(0, 0.2, -0.4) * CFrame.Angles(math.rad(-60), 0, 0)
		local screen = Instance.new("Part")
		screen.Name = "Screen"
		screen.Size = Vector3.new(0.42, 0.8, 0.05)
		screen.Color = Color3.fromRGB(120, 200, 255)
		screen.Material = Enum.Material.Neon
		screen.CanCollide = false
		screen.Massless = true
		screen.CFrame = phone.CFrame * CFrame.new(0, 0, 0.06)
		for _, p in { phone, screen } do
			local w = Instance.new("WeldConstraint")
			w.Part0 = hand
			w.Part1 = p
			w.Parent = p
			p.Parent = rig
		end
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(120, 200, 255)
		light.Range = 6
		light.Parent = screen
	end
	local upper = rig:FindFirstChild("RightUpperArm")
	local shoulder = upper and upper:FindFirstChild("RightShoulder")
	if shoulder and shoulder:IsA("Motor6D") then
		shoulder.C0 = shoulder.C0 * CFrame.Angles(math.rad(70), 0, 0)
	end
	rig.Parent = workspace
	return rig
end

local function fillLobe(lobe)
	if lobe.Owner then
		return
	end
	local name = NAMES[lobe.Index]
	lobe.NpcName = name
	lobe.Level = rng:NextInteger(1, 3)
	LobeService.ClearAll(lobe)
	for _ = 1, rng:NextInteger(5, 8) do
		local rarity = RarityConfig.Roll(rng, 1.2)
		if rarity.Index > 5 then
			rarity = RarityConfig.List[5]
		end
		local def = BrainrotCatalog.PickFromRarity(rng, rarity.Name, false)
		LobeService.Place(lobe, { Id = def.Id, Mut = MutationConfig.Roll(rng, 2, false), Lv = rng:NextInteger(1, 3) })
	end
	LobeService.ApplyTier(lobe)
	LobeService.UpdateLabel(lobe)
	NpcKids.Rigs[lobe.Index] = buildKid(name, lobe.CF * CFrame.new(-3, 4.6, -11))
	MostRottedBoard.Extra[lobe.Index] = { Name = name, Cells = rng:NextInteger(2, 900) * 10 ^ rng:NextInteger(2, 6), Found = rng:NextInteger(3, 41) }
end

local function evict(lobe)
	if NpcKids.Rigs[lobe.Index] then
		NpcKids.Rigs[lobe.Index]:Destroy()
		NpcKids.Rigs[lobe.Index] = nil
	end
	MostRottedBoard.Extra[lobe.Index] = nil
	lobe.NpcName = nil
end

function NpcKids.Start()
	for _, lobe in LobeService.Lobes do
		fillLobe(lobe)
	end
	GameSignals.On("LobeClaiming", evict)
	GameSignals.On("LobeReleased", function(lobe)
		task.delay(3, fillLobe, lobe)
	end)
	task.spawn(function()
		while true do
			task.wait(2.5)
			local rigs = {}
			for _, rig in NpcKids.Rigs do
				table.insert(rigs, rig)
			end
			if #rigs > 0 then
				local rig = rigs[rng:NextInteger(1, #rigs)]
				if rig.Parent then
					HudNotify.Popup(nil, SLANG[rng:NextInteger(1, #SLANG)], HOODIES[rng:NextInteger(1, #HOODIES)], rig:GetPivot().Position + Vector3.new(0, 4, 0))
				end
			end
		end
	end)
end

return NpcKids
