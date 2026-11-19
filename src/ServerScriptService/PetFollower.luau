local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local BrainrotModelKit = require(RS.BrainrotModelKit)
local DataService = require(script.Parent.DataService)
local GameSignals = require(script.Parent.GameSignals)

local PetFollower = { Pets = {} }

local function bestEntry(p)
	local best, bestIncome
	for _, entry in p.Podiums do
		local income = BrainrotModelKit.Income(entry)
		if not bestIncome or income > bestIncome then
			best, bestIncome = entry, income
		end
	end
	return best
end

local function clear(player)
	local pet = PetFollower.Pets[player]
	if pet then
		pet.Model:Destroy()
		PetFollower.Pets[player] = nil
	end
end

local function refresh(player: Player)
	local p = DataService.Get(player)
	if not p then
		return
	end
	local entry = bestEntry(p)
	local key = entry and (entry.Id .. ":" .. tostring(entry.Mut) .. ":" .. (entry.Lv or 1)) or nil
	local pet = PetFollower.Pets[player]
	if pet and pet.Key == key then
		return
	end
	clear(player)
	if not entry then
		return
	end
	local m = BrainrotModelKit.Build(entry, { scale = 0.4, tag = false, fx = false })
	m.Name = player.Name .. "Pet"
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		m:PivotTo(root.CFrame * CFrame.new(3, -2.5, 3))
	end
	local set = BrainrotModelKit.MakeGlider(m)
	m.Parent = workspace
	m.PrimaryPart:SetNetworkOwner(nil)
	PetFollower.Pets[player] = { Model = m, Set = set, Key = key, Pos = m:GetPivot().Position }
end

function PetFollower.Start()
	GameSignals.On("PlayerLeaving", clear)
	task.spawn(function()
		while true do
			task.wait(2)
			for _, player in DataService.Ready() do
				refresh(player)
			end
		end
	end)
	RunService.Heartbeat:Connect(function(dt)
		local t = os.clock()
		for player, pet in PetFollower.Pets do
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local goal = (root.CFrame * CFrame.new(3, -2.6 + math.abs(math.sin(t * 6)) * 0.6, 3)).Position
				pet.Pos = pet.Pos:Lerp(goal, math.min(1, dt * 6))
				if (pet.Pos - goal).Magnitude > 40 then
					pet.Pos = goal
				end
				pet.Set(CFrame.lookAt(pet.Pos, pet.Pos + root.CFrame.LookVector * Vector3.new(1, 0, 1)))
			end
		end
	end)
end

return PetFollower
