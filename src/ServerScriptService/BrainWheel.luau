local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local NumberFormat = require(RS.NumberFormat)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local HudNotify = require(script.Parent.HudNotify)

local BrainWheel = { Spinning = false }

local FREE_EVERY = 600

-- One prize per slice, clockwise from the top.
BrainWheel.Prizes = {
	{ Text = "60s OF INCOME", Give = function(player)
		return Economy.Add(player, math.max(500, Economy.Cps(player) * 60))
	end },
	{ Text = "SIGMA MINDSET", Give = function(player)
		Economy.AddBuff(player, "Sigma Mindset", 90)
	end },
	{ Text = "🧠500", Give = function(player)
		Economy.Add(player, 500)
	end },
	{ Text = "ENERGY DRINK", Give = function(player)
		Economy.AddBuff(player, "Energy Drink", 180)
	end },
	{ Text = "+50% BRAIN ROT", Give = function(player)
		require(script.Parent.RotMeter).Add(player, 50)
	end },
	{ Text = "3 MIN OF INCOME", Give = function(player)
		Economy.Add(player, math.max(2000, Economy.Cps(player) * 180))
	end },
	{ Text = "BASIC THOUGHT BUBBLE", Give = function(player)
		local p = DataService.Get(player)
		p.Cells += 500
		if not require(script.Parent.ThoughtBubbleHatch).Add(player, "Basic") then
			p.Cells -= 500
			Economy.Add(player, 1000)
		end
	end },
	{ Text = "MEGA SIGMA", Give = function(player)
		Economy.AddBuff(player, "Sigma Mindset", 240)
	end },
}

function BrainWheel.Spin(player: Player)
	local p = DataService.Get(player)
	if not p or BrainWheel.Spinning then
		return
	end
	if os.time() < p.WheelAt then
		HudNotify.PopupOver(player, "FREE SPIN IN " .. NumberFormat.Clock(p.WheelAt - os.time()), Color3.fromRGB(200, 200, 200))
		return
	end
	p.WheelAt = os.time() + FREE_EVERY
	BrainWheel.Spinning = true
	local wheel = workspace.BrainWorld.BrainWheel
	local hub = wheel.Hub
	local slices = wheel.Slices:GetChildren()
	local base = {}
	for _, s in slices do
		base[s] = hub.CFrame:ToObjectSpace(s.CFrame)
	end
	local win = math.random(1, #BrainWheel.Prizes)
	local target = math.rad(360 * 4) - math.rad((win - 0.5) * 45)
	local t0, duration = os.clock(), 3.5
	while true do
		local k = math.min(1, (os.clock() - t0) / duration)
		local angle = target * (1 - (1 - k) ^ 3)
		for _, s in slices do
			s.CFrame = hub.CFrame * CFrame.Angles(angle, 0, 0) * base[s]
		end
		if k >= 1 then
			break
		end
		RunService.Heartbeat:Wait()
	end
	local prize = BrainWheel.Prizes[win]
	prize.Give(player)
	DataService.Bump(player, "WheelSpins", 1)
	HudNotify.Popup(nil, "🎡 " .. prize.Text .. "!", Color3.fromRGB(255, 215, 70), hub.Position + Vector3.new(0, 10, 0), true)
	HudNotify.Feed(player, "🎡 Brain Wheel: " .. prize.Text .. ". Next free spin in 10:00.")
	task.wait(1)
	for _, s in slices do
		s.CFrame = hub.CFrame * base[s]
	end
	BrainWheel.Spinning = false
end

function BrainWheel.Start()
	workspace.BrainWorld.BrainWheel.Sign.Prompt.Triggered:Connect(BrainWheel.Spin)
	DataService.AddStateField(function(_, s, p)
		s.WheelIn = math.max(0, p.WheelAt - os.time())
	end)
end

return BrainWheel
