local Players = game:GetService("Players")
local WorldBuilder = require(script.Parent.WorldBuilder)
local DataService = require(script.Parent.DataService)
local HudNotify = require(script.Parent.HudNotify)

local SubconsciousGate = {}

local REQUIRED_WASHES = 5

local function inside(pos: Vector3)
	local c = WorldBuilder.Layout.Subconscious
	return math.abs(pos.X - c.X) < 26 and pos.Z > c.Z - 26 and pos.Z < c.Z + 16 and pos.Y < 30
end

function SubconsciousGate.Start()
	local c = WorldBuilder.Layout.Subconscious
	local warned = {}
	task.spawn(function()
		while true do
			task.wait(0.25)
			for _, player in Players:GetPlayers() do
				local p = DataService.Get(player)
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if p and root and p.Washes < REQUIRED_WASHES and inside(root.Position) then
					player.Character:PivotTo(CFrame.new(c + Vector3.new(0, 4, 24)))
					if (warned[player] or 0) < os.clock() then
						warned[player] = os.clock() + 3
						HudNotify.PopupOver(player, "NEEDS BRAIN WASH 5", Color3.fromRGB(200, 120, 255), true)
					end
				end
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		warned[player] = nil
	end)
end

return SubconsciousGate
