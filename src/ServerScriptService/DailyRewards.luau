local RS = game:GetService("ReplicatedStorage")
local NumberFormat = require(RS.NumberFormat)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)

local DailyRewards = {}

DailyRewards.Streak = { 1e3, 3e3, 1e4, 3e4, 1e5, 3e5, 1e6 }

function DailyRewards.Claim(player: Player)
	local p = DataService.Get(player)
	local today = os.time() // 86400
	if p.Daily.Day >= today then
		return
	end
	p.Daily.Streak = (p.Daily.Day == today - 1) and (p.Daily.Streak % #DailyRewards.Streak) + 1 or 1
	p.Daily.Day = today
	local day = p.Daily.Streak
	local reward = DailyRewards.Streak[day] * (1 + p.Washes)
	Economy.Add(player, reward)
	if day == #DailyRewards.Streak then
		Economy.AddBuff(player, "Sigma Mindset", 300)
	end
	task.delay(3, function()
		HudNotify.PopupOver(player, "DAY " .. day .. " STREAK! +" .. NumberFormat.Cells(reward), Color3.fromRGB(255, 215, 70), true)
		HudNotify.Feed(player, "🎁 Daily login, day " .. day .. "/7: +" .. NumberFormat.Cells(reward) .. (day == 7 and " + Sigma Mindset" or ""))
	end)
end

function DailyRewards.Start()
	GameSignals.On("PlayerReady", DailyRewards.Claim)
	DataService.AddStateField(function(_, s, p)
		s.DailyStreak = p.Daily.Streak
	end)
end

return DailyRewards
