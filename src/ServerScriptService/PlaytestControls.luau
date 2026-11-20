local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

-- Studio only: lets a play-test session drive the live services (the plugin's require has its own module cache).
local PlaytestControls = {}

local function service(name)
	return require(script.Parent[name])
end

local Actions = {}

function Actions.Give(player, cells)
	service("BrainCellEconomy").Add(player, cells)
end

function Actions.BuyFirstMeme(player)
	local line = service("SynapseBelt").Lines.Main
	local meme = line.Memes[#line.Memes]
	player.Character:PivotTo(meme.Model:GetPivot() * CFrame.new(0, 3, -5))
	task.wait(0.2)
	service("SynapseBelt").Buy(player, line, meme)
end

function Actions.GiveBrainrot(player, id, mut, lv)
	local entry = { Id = id, Mut = mut, Lv = lv or 1 }
	service("LobeService").Place(service("LobeService").LobeOf(player), entry)
	require(script.Parent.GameSignals).Emit("Acquired", player, entry, "gift")
end

function Actions.GoTo(player, x, y, z)
	player.Character:PivotTo(CFrame.new(x, y, z))
end

function Actions.GoHome(player)
	local lobe = service("LobeService").LobeOf(player)
	player.Character:PivotTo(lobe.CF * CFrame.new(0, 4, -6))
end

function Actions.Summary(player)
	local p = service("DataService").Get(player)
	local rt = service("DataService").Rt(player)
	local podiums = 0
	for _ in p.Podiums do
		podiums += 1
	end
	return string.format("cells=%d podiums=%d carrying=%d lobe=%d rot=%d", p.Cells, podiums, #rt.Carrying, rt.Lobe and rt.Lobe.Index or 0, rt.Rot or 0)
end

local SHOWCASE = {
	{ 41, "Sigma", 2 }, { 44, "Brain Freeze", 2 }, { 39, "Golden", 5 }, { 46, nil, 2 }, { 34, "Max Aura", 1 }, { 36, "Rotten", 3 },
	{ 42, "Ohio", 1 }, { 40, nil, 2 }, { 33, "Rizzed", 1 }, { 30, "Brain Freeze", 2 }, { 53, "Golden", 4 }, { 57, nil, 3 },
	{ 50, "Galaxy Brain", 2 }, { 48, "Rizzed", 3 }, { 49, nil, 1 }, { 54, nil, 2 }, { 47, "Golden", 1 }, { 51, nil, 1 },
}

function Actions.SetupShowcase(player)
	local p, rt = service("DataService").Get(player), service("DataService").Rt(player)
	local LobeService = service("LobeService")
	local lobe = LobeService.LobeOf(player)
	p.Washes, p.AuraPoints, p.Cells, p.LobeLevel = 4, 6, 2.43e9, 4
	p.Upgrades = { Income = 8, Speed = 6, Luck = 7, Defense = 5, Thoughts = 10 }
	p.Gear = { SlapperSupremo = true, SigmaSneakers = true, NoodleArm = true }
	p.Pedia = {}
	for id = 1, 40 do
		p.Pedia[tostring(id)] = { Normal = true, Golden = id % 3 == 0 or nil, Rizzed = id % 5 == 0 or nil }
	end
	LobeService.ClearAll(lobe)
	p.Podiums = {}
	lobe.Entries = p.Podiums
	lobe.Level = 4
	for _, row in SHOWCASE do
		LobeService.Place(lobe, { Id = row[1], Mut = row[2], Lv = row[3] })
	end
	LobeService.ApplyTier(lobe)
	LobeService.UpdateLabel(lobe)
	p.Bubbles = { ["1"] = { Kind = "Galaxy", ReadyAt = os.time() + 151 }, ["2"] = { Kind = "Gold", ReadyAt = os.time() + 43 }, ["3"] = { Kind = "Gold", ReadyAt = os.time() }, ["4"] = { Kind = "Basic", ReadyAt = os.time() + 12 } }
	service("ThoughtBubbleHatch").Refresh(lobe)
	require(script.Parent.GameSignals).Emit("LobeUpgraded", player, lobe)
	rt.Rot = 90
	service("Brainpedia").Record(player, { Id = 42, Lv = 1 })
end

function Actions.BlendCatch(player, id, mut)
	local entry = { Id = id, Mut = mut, Lv = 1 }
	local p = service("DataService").Get(player)
	p.Pedia[tostring(id)] = nil
	service("LobeService").Place(service("LobeService").LobeOf(player), entry)
	require(script.Parent.GameSignals).Emit("Acquired", player, entry, "blend")
end

function Actions.StealFrom(player, lobeIndex)
	local LobeService = service("LobeService")
	local lobe = LobeService.Lobes[lobeIndex]
	local best, bestIncome = nil, -1
	for idx, entry in lobe.Entries do
		local income = require(game:GetService("ReplicatedStorage").BrainrotModelKit).Income(entry)
		if income > bestIncome then
			best, bestIncome = tonumber(idx), income
		end
	end
	player.Character:PivotTo(LobeService.PodiumCFrame(lobe, best) * CFrame.new(0, 4, 4))
	task.wait(0.2)
	service("StealService").TrySteal(player, lobe, best)
	task.wait(0.3)
	player.Character:PivotTo(lobe.CF * CFrame.new(0, 4, -26) * CFrame.Angles(0, math.pi, 0))
	lobe.MindBlockUntil = os.clock() + 30
	lobe.Model.MindBlockField.Material = Enum.Material.Neon
	lobe.Model.MindBlockField.Transparency = 0.65
	task.wait(0.2)
	local root = player.Character.HumanoidRootPart
	local kid = service("NpcKids").Rigs[lobeIndex]
	if kid then
		local at = root.CFrame * CFrame.new(3.5, 0.6, 2.5)
		local kidPos = kid:GetPivot().Position
		local move = CFrame.lookAt(at.Position, root.Position) * kid:GetPivot():Inverse()
		for _, m in kid.Parent:GetChildren() do
			if m:IsA("Model") and (m:GetPivot().Position - kidPos).Magnitude < 6 then
				m:PivotTo(move * m:GetPivot())
			end
		end
	end
	require(script.Parent.HudNotify).Popup(nil, "✋ FOCUS SLAP!", Color3.fromRGB(255, 230, 120), root.Position + Vector3.new(2, 3, 0), true)
	return root.Position
end

function Actions.Capture(on)
	workspace:SetAttribute("Capture16x9", on)
end

function Actions.Call(serviceName, method, ...)
	local result = service(serviceName)[method](...)
	return type(result) ~= "table" and result or nil
end

function Actions.Event(name)
	task.spawn(service("EventScheduler").Trigger, name)
end

function PlaytestControls.Start()
	if not RunService:IsStudio() then
		return
	end
	local fn = Instance.new("BindableFunction")
	fn.Name = "PlaytestControls"
	fn.OnInvoke = function(action, ...)
		return Actions[action](...)
	end
	fn.Parent = ServerStorage
end

return PlaytestControls
