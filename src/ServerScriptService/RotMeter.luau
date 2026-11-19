local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)
local WorldBuilder = require(script.Parent.WorldBuilder)

local RotMeter = {}

local FRENZY = 20

function RotMeter.Add(player: Player, amount: number)
	local rt = DataService.Rt(player)
	if not rt or Economy.HasBuff(player, "Fully Rotted") then
		return
	end
	rt.Rot = math.min(100, rt.Rot + amount)
	if rt.Rot >= 100 then
		rt.Rot = 0
		Economy.AddBuff(player, "Fully Rotted", FRENZY)
		DataService.Bump(player, "FullyRotted", 1)
		HudNotify.PopupOver(player, "FULLY ROTTED! x3", Color3.fromRGB(130, 255, 80), true)
		HudNotify.Feed(nil, "🤢 " .. player.DisplayName .. " is FULLY ROTTED! Income x3 for 20s")
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local burst = WorldBuilder.Part(workspace, { Name = "GooExplosion", Size = Vector3.one, Position = root.Position, Transparency = 1, CanCollide = false, CanQuery = false })
			local e = WorldBuilder.Sparkles(burst, WorldBuilder.Colors.Goo, 0, "Goo")
			e.Speed = NumberRange.new(15, 25)
			e.Acceleration = Vector3.new(0, -30, 0)
			e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0.3) })
			e:Emit(80)
			game:GetService("Debris"):AddItem(burst, 3)
		end
	end
end

function RotMeter.Start()
	GameSignals.On("Bought", function(player)
		RotMeter.Add(player, 4)
	end)
	GameSignals.On("Acquired", function(player)
		RotMeter.Add(player, 2)
	end)
	DataService.AddStateField(function(player, s, _, rt)
		s.Rot = rt.Rot
		local left = (rt.Buffs["Fully Rotted"] or 0) - os.clock()
		s.RotFrenzy = left > 0 and left or 0
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in DataService.Ready() do
				local n = 0
				for _ in DataService.Get(player).Podiums do
					n += 1
				end
				RotMeter.Add(player, math.min(1.5, 0.05 * n))
			end
		end
	end)
end

return RotMeter
