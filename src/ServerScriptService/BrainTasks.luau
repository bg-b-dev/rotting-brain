local RS = game:GetService("ReplicatedStorage")
local NumberFormat = require(RS.NumberFormat)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)

local BrainTasks = {}

local ACTIVE = 3

-- Text, stat counter, goal, base reward in Brain Cells.
BrainTasks.List = {
	{ "Buy 3 memes off the belt", "Bought", 3, 500 },
	{ "Discover 5 brainrots", "Discovered", 5, 1500 },
	{ "Steal a brainrot from a rival Lobe", "Stolen", 1, 1000 },
	{ "Focus Slap 3 times", "Slaps", 3, 800 },
	{ "Stop 2 Productivity Pixies", "PixiesStopped", 2, 1500 },
	{ "Raise a Mind Block", "MindBlocks", 1, 500 },
	{ "Blend a meme in the Meme Blender", "Blends", 1, 3000 },
	{ "Pop 2 Thought Bubbles", "BubblesPopped", 2, 2000 },
	{ "Buy 3 upgrades", "Upgrades", 3, 2500 },
	{ "Upgrade your Lobe", "LobeUpgrades", 1, 3000 },
	{ "Dodge a Touch Grass Wave on floor 2", "WavesSurvived", 1, 4000 },
	{ "Go Fully Rotted", "FullyRotted", 1, 5000 },
	{ "Spin the Brain Wheel", "WheelSpins", 1, 500 },
	{ "Win the Meme Quiz", "QuizWins", 1, 1500 },
	{ "Finish the Grass Dodge track", "DodgeRuns", 1, 1500 },
	{ "Live through 3 brain events", "EventsSeen", 3, 2000 },
	{ "Buy gear at the Dopamine Mart", "GearBought", 1, 2000 },
	{ "Buy 10 memes", "Bought", 10, 2000 },
	{ "Discover 15 brainrots", "Discovered", 15, 10000 },
	{ "Buy 25 memes", "Bought", 25, 10000 },
	{ "Steal 5 brainrots", "Stolen", 5, 8000 },
	{ "Stop 10 Productivity Pixies", "PixiesStopped", 10, 10000 },
	{ "Blend 5 memes", "Blends", 5, 15000 },
	{ "Brain Wash once", "Washes", 1, 50000 },
}

local function assignNext(p, slot)
	p.TaskCursor = ((p.TaskCursor or 0) % #BrainTasks.List) + 1
	local t = BrainTasks.List[p.TaskCursor]
	p.Tasks[slot] = { Index = p.TaskCursor, Start = p.Stats[t[2]] or 0 }
end

local function check(player: Player)
	local p = DataService.Get(player)
	if not p then
		return
	end
	for slot = 1, ACTIVE do
		local task_ = p.Tasks[slot]
		if not task_ then
			assignNext(p, slot)
		else
			local t = BrainTasks.List[task_.Index]
			if (p.Stats[t[2]] or 0) - task_.Start >= t[3] then
				local reward = t[4] * (1 + 2 * p.Washes)
				Economy.Add(player, reward)
				HudNotify.PopupOver(player, "TASK DONE! +" .. NumberFormat.Cells(reward), Color3.fromRGB(130, 255, 80), true)
				HudNotify.Feed(player, "✅ Brain Task: " .. t[1] .. " (+" .. NumberFormat.Cells(reward) .. ")")
				assignNext(p, slot)
			end
		end
	end
end

function BrainTasks.Start()
	GameSignals.On("PlayerReady", function(player)
		local p = DataService.Get(player)
		local fixed = {}
		for slot = 1, ACTIVE do
			fixed[slot] = p.Tasks[slot] or p.Tasks[tostring(slot)]
		end
		p.Tasks = fixed
		check(player)
	end)
	GameSignals.On("Stat", check)
	DataService.AddStateField(function(_, s, p)
		s.Tasks = {}
		for slot = 1, ACTIVE do
			local task_ = p.Tasks[slot]
			if task_ then
				local t = BrainTasks.List[task_.Index]
				table.insert(s.Tasks, { Text = t[1], Progress = math.min(t[3], (p.Stats[t[2]] or 0) - task_.Start), Goal = t[3] })
			end
		end
	end)
end

return BrainTasks
