local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)
local WorldBuilder = require(script.Parent.WorldBuilder)
local SynapseBelt = require(script.Parent.SynapseBelt)
local MutationService = require(script.Parent.MutationService)
local PixieRaid = require(script.Parent.ProductivityPixieRaid)
local TouchGrassWave = require(script.Parent.TouchGrassWave)

local EventScheduler = { Current = nil, NextName = nil, NextAt = 0 }

local GAP = 60
local RAINBOW = { Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 160, 40), Color3.fromRGB(255, 230, 60), Color3.fromRGB(80, 220, 90), Color3.fromRGB(70, 160, 255), Color3.fromRGB(170, 90, 255) }

local function brainLag(duration)
	SynapseBelt.SpeedMult = 0
	local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	local sat = cc.Saturation
	TweenService:Create(cc, TweenInfo.new(0.8), { Saturation = -0.8 }):Play()
	local lobe = WorldBuilder.Layout.MemeLobe
	local ring = Instance.new("Model")
	ring.Name = "BufferingCircle"
	local dots = {}
	for i = 1, 10 do
		dots[i] = WorldBuilder.Part(ring, { Name = "Dot", Shape = Enum.PartType.Ball, Size = Vector3.one * 3, Color = Color3.new(1, 1, 1), Material = Enum.Material.Neon, CanCollide = false, CanQuery = false })
	end
	ring.Parent = workspace
	local rare = SynapseBelt.DropRare()
	if rare then
		HudNotify.Popup(nil, "RARE MEME DROPPED!", Color3.fromRGB(70, 150, 255), rare.Model:GetPivot().Position + Vector3.new(0, 6, 0), true)
	end
	local stop = os.clock() + duration
	while os.clock() < stop do
		local t = os.clock() * 4
		for i, d in dots do
			local a = t + i / #dots * math.pi * 2
			d.Position = lobe + Vector3.new(math.cos(a) * 14, 42 + math.sin(a) * 14, 32)
			d.Transparency = (i / #dots)
		end
		task.wait(0.05)
	end
	ring:Destroy()
	SynapseBelt.SpeedMult = 1
	TweenService:Create(cc, TweenInfo.new(0.8), { Saturation = sat }):Play()
end

local function dopamineRush(duration)
	Economy.GlobalIncomeMult = 2
	local confetti = MutationService.SkyParticles("Confetti", Color3.fromRGB(255, 120, 200), 150, 1)
	local seq = {}
	for i, c in RAINBOW do
		table.insert(seq, ColorSequenceKeypoint.new((i - 1) / (#RAINBOW - 1), c))
	end
	confetti:FindFirstChildOfClass("ParticleEmitter").Color = ColorSequence.new(seq)
	local neurons = workspace.BrainWorld.MemeLobe.Neurons:GetChildren()
	local base = {}
	for i, n in neurons do
		base[i] = n.Color
	end
	local stop = os.clock() + duration
	local k = 0
	while os.clock() < stop do
		k += 1
		for i, n in neurons do
			n.Color = RAINBOW[(i + k) % #RAINBOW + 1]
		end
		task.wait(0.25)
	end
	for i, n in neurons do
		n.Color = base[i]
	end
	confetti:Destroy()
	Economy.GlobalIncomeMult = 1
end

EventScheduler.Events = {
	{ Name = "Brain Freeze", Icon = "🧊", Duration = 20, Text = "Every meme on the belt mutates!", Run = MutationService.BrainFreeze },
	{ Name = "Homework Raid", Icon = "📋", Duration = 30, Text = "Productivity Pixies incoming! Slap them [F] for bounties!", Run = PixieRaid.StartHomeworkRaid },
	{ Name = "Touch Grass Wave", Icon = "🌱", Duration = 9, Text = "GRASS WALL INCOMING! Hide on your 2nd floor!", Run = function()
		TouchGrassWave.Run()
	end },
	{ Name = "Brain Lag", Icon = "⏳", Duration = 15, Text = "The belt is buffering... a rare meme dropped!", Run = brainLag },
	{ Name = "Dopamine Rush", Icon = "🌈", Duration = 30, Text = "All Lobes pay x2!", Run = dopamineRush },
}

local function byName(name)
	for _, e in EventScheduler.Events do
		if e.Name == name then
			return e
		end
	end
	return nil
end

function EventScheduler.Trigger(name: string)
	local event = byName(name)
	if not event or EventScheduler.Current then
		return
	end
	EventScheduler.Current = { Name = event.Name, Icon = event.Icon, EndsAt = os.clock() + event.Duration }
	HudNotify.Feed(nil, event.Icon .. " " .. string.upper(event.Name) .. "! " .. event.Text)
	HudNotify.Alert(nil, event.Icon .. " " .. string.upper(event.Name) .. "! " .. event.Icon, Color3.fromRGB(255, 215, 70))
	GameSignals.Emit("EventStarted", event.Name)
	for _, player in DataService.Ready() do
		HudNotify.PopupOver(player, string.upper(event.Name) .. "!", Color3.fromRGB(255, 215, 70), true)
		DataService.Bump(player, "EventsSeen", 1)
	end
	local ok, err = pcall(event.Run, event.Duration)
	if not ok then
		warn("Event " .. name .. ": " .. tostring(err))
	end
	EventScheduler.Current = nil
end

function EventScheduler.Start()
	DataService.AddStateField(function(_, s)
		local cur = EventScheduler.Current
		if cur then
			s.Event = { Name = cur.Name, Icon = cur.Icon, Left = math.max(0, cur.EndsAt - os.clock()) }
		elseif EventScheduler.NextName then
			s.Next = { Name = EventScheduler.NextName, In = math.max(0, EventScheduler.NextAt - os.clock()) }
		end
	end)
	task.spawn(function()
		local order = {}
		while true do
			if #order == 0 then
				for _, e in EventScheduler.Events do
					table.insert(order, math.random(1, #order + 1), e.Name)
				end
			end
			EventScheduler.NextName = table.remove(order, 1)
			EventScheduler.NextAt = os.clock() + GAP
			task.wait(GAP)
			EventScheduler.Trigger(EventScheduler.NextName)
		end
	end)
end

return EventScheduler
