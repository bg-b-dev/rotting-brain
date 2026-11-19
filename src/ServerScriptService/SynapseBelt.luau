local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local BrainrotModelKit = require(RS.BrainrotModelKit)
local BrainrotCatalog = require(RS.BrainrotCatalog)
local RarityConfig = require(RS.RarityConfig)
local MutationConfig = require(RS.MutationConfig)
local NumberFormat = require(RS.NumberFormat)
local WorldBuilder = require(script.Parent.WorldBuilder)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local CarryService = require(script.Parent.CarryService)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)

local SynapseBelt = { SpeedMult = 1, ForceMutation = false, Lines = {} }

local rng = Random.new()

local function makeLine(name, path, center, speed, interval, subconscious)
	local segs, total = {}, 0
	for i = 1, #path - 1 do
		local len = (path[i + 1] - path[i]).Magnitude
		table.insert(segs, { A = path[i], B = path[i + 1], Start = total, Len = len })
		total += len
	end
	local line = { Name = name, Segs = segs, Total = total, Center = center, Speed = speed, Interval = interval, Subconscious = subconscious, Memes = {}, Timer = 0 }
	SynapseBelt.Lines[name] = line
	return line
end

local function pointAt(line, d)
	for _, s in line.Segs do
		if d <= s.Start + s.Len then
			return s.A:Lerp(s.B, (d - s.Start) / s.Len)
		end
	end
	return line.Segs[#line.Segs].B
end

local function facing(line, pos)
	local v = pos - line.Center
	if math.abs(v.X) >= math.abs(v.Z) then
		return Vector3.new(math.sign(v.X), 0, 0)
	end
	return Vector3.new(0, 0, math.sign(v.Z))
end

local function priceOf(entry)
	return BrainrotCatalog.Get(entry.Id).Price * MutationConfig.Mult(entry.Mut)
end

local function retag(meme)
	BrainrotModelKit.AttachTag(meme.Model, meme.Entry, "BUY " .. NumberFormat.Cells(priceOf(meme.Entry)))
	meme.Prompt.ObjectText = NumberFormat.Cells(priceOf(meme.Entry))
end

function SynapseBelt.Buy(player: Player, line, meme)
	if not meme.Model.Parent then
		return
	end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local p = DataService.Get(player)
	if not (root and p) then
		return
	end
	local reach = p.Gear.NoodleArm and 26 or 16
	if (root.Position - meme.Model:GetPivot().Position).Magnitude > reach then
		return
	end
	if CarryService.IsFull(player) then
		HudNotify.PopupOver(player, "HANDS FULL! RUN TO YOUR LOBE", Color3.fromRGB(255, 200, 60))
		return
	end
	if not Economy.TrySpend(player, priceOf(meme.Entry)) then
		return
	end
	table.remove(line.Memes, table.find(line.Memes, meme))
	meme.Model:Destroy()
	CarryService.PickUp(player, meme.Entry, nil)
	DataService.Bump(player, "Bought", 1)
	GameSignals.Emit("Bought", player, meme.Entry)
	local mut = meme.Entry.Mut and MutationConfig.ByName[meme.Entry.Mut]
	HudNotify.PopupOver(player, mut and mut.Popup or "+100 AURA", mut and mut.Color or Color3.fromRGB(255, 158, 199), true)
end

function SynapseBelt.Spawn(line, opts)
	opts = opts or {}
	local luck = Economy.BestLuck()
	local rarity = RarityConfig.Roll(rng, luck, opts.MinRarity)
	if line.Subconscious then
		rarity = RarityConfig.Roll(rng, luck + 2, 6)
	end
	local def = BrainrotCatalog.PickFromRarity(rng, rarity.Name, line.Subconscious)
	local entry = { Id = def.Id, Mut = MutationConfig.Roll(rng, luck, SynapseBelt.ForceMutation), Lv = 1 }
	local model = BrainrotModelKit.Build(entry)
	local d = opts.At or 0
	local pos = pointAt(line, d)
	model:PivotTo(CFrame.lookAt(pos, pos + facing(line, pos)))
	local setTarget = BrainrotModelKit.MakeGlider(model)
	local prompt = WorldBuilder.Prompt(model.PrimaryPart, "Buy", "", 0)
	prompt.Name = "BuyPrompt"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = 26
	local meme = { Entry = entry, Model = model, D = d, Set = setTarget, Prompt = prompt, Phase = rng:NextNumber(0, 6) }
	retag(meme)
	prompt.Triggered:Connect(function(player)
		SynapseBelt.Buy(player, line, meme)
	end)
	model.Parent = workspace:FindFirstChild("BeltMemes")
	model.PrimaryPart:SetNetworkOwner(nil)
	table.insert(line.Memes, meme)
	return meme
end

function SynapseBelt.MutateAll(line)
	for _, meme in line.Memes do
		if not meme.Entry.Mut then
			meme.Entry.Mut = MutationConfig.Roll(rng, Economy.BestLuck(), true)
			BrainrotModelKit.ApplyMutation(meme.Model, meme.Entry.Mut)
			retag(meme)
		end
	end
end

function SynapseBelt.DropRare()
	local line = SynapseBelt.Lines.Main
	return SynapseBelt.Spawn(line, { MinRarity = 3, At = rng:NextNumber(40, line.Total - 40) })
end

local function flashNeurons()
	local neurons = workspace.BrainWorld.MemeLobe.Neurons:GetChildren()
	while true do
		task.wait(0.2)
		local n = neurons[rng:NextInteger(1, #neurons)]
		local base = n.Color
		n.Color = Color3.new(1, 1, 1)
		n.Size = Vector3.one * 3.4
		task.delay(0.15, function()
			n.Color = base
			n.Size = Vector3.one * 2.2
		end)
	end
end

function SynapseBelt.Start()
	local folder = Instance.new("Folder")
	folder.Name = "BeltMemes"
	folder.Parent = workspace
	local L = WorldBuilder.Layout
	makeLine("Main", L.BeltPath, Vector3.new(0, 0, -37.5), 7, 2.4, false)
	local s = L.Subconscious
	makeLine("Dream", { s + Vector3.new(0, 1.6, -22), s + Vector3.new(0, 1.6, 6) }, s + Vector3.new(-20, 0, 0), 3, 9, true)
	local pulse = WorldBuilder.Part(workspace.BrainWorld.SynapseBelt, { Name = "SynapsePulse", Shape = Enum.PartType.Ball, Size = Vector3.one * 2.4, Color = WorldBuilder.Colors.Nerve, Material = Enum.Material.Neon, CanCollide = false, CanQuery = false })
	local pulseD = 0
	task.spawn(flashNeurons)
	for _ = 1, 14 do
		SynapseBelt.Spawn(SynapseBelt.Lines.Main, { At = rng:NextNumber(0, SynapseBelt.Lines.Main.Total - 5) })
	end
	RunService.Heartbeat:Connect(function(dt)
		local t = os.clock()
		for _, line in SynapseBelt.Lines do
			local speed = line.Speed * (line.Name == "Main" and SynapseBelt.SpeedMult or 1)
			if speed > 0 then
				line.Timer += dt
				if line.Timer >= line.Interval / (SynapseBelt.ForceMutation and 2 or 1) then
					line.Timer = 0
					if #line.Memes < 30 then
						SynapseBelt.Spawn(line)
					end
				end
			end
			for i = #line.Memes, 1, -1 do
				local meme = line.Memes[i]
				meme.D += speed * dt
				if meme.D >= line.Total or not meme.Model.Parent then
					meme.Model:Destroy()
					table.remove(line.Memes, i)
				else
					local pos = pointAt(line, meme.D) + Vector3.new(0, math.abs(math.sin(t * 5 + meme.Phase)) * 0.4, 0)
					meme.Set(CFrame.lookAt(pos, pos + facing(line, pos)))
				end
			end
		end
		local main = SynapseBelt.Lines.Main
		pulseD = (pulseD + 40 * SynapseBelt.SpeedMult * dt) % main.Total
		pulse.Position = pointAt(main, pulseD) + Vector3.new(0, 0.6, 0)
	end)
end

return SynapseBelt
