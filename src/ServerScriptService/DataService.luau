local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local Remotes = require(game:GetService("ReplicatedStorage").Remotes)
local GameSignals = require(script.Parent.GameSignals)

local DataService = { Profiles = {}, Runtime = {}, StateFields = {} }

local store
pcall(function()
	store = DataStoreService:GetDataStore("RottingBrain_v1")
end)

local function defaultProfile()
	return {
		Cells = 100, TotalEarned = 0, Washes = 0, AuraPoints = 0, Perks = {},
		Upgrades = { Income = 0, Speed = 0, Luck = 0, Defense = 0, Thoughts = 0 },
		LobeLevel = 1, FogLevel = 1, Podiums = {}, Pedia = {}, Gear = {}, Bubbles = {}, Tasks = {}, Stats = {},
		Daily = { Day = 0, Streak = 0 }, WheelAt = 0, LastSeen = 0, LastCps = 0,
	}
end

local function fillDefaults(into, defaults)
	for k, v in defaults do
		if into[k] == nil then
			into[k] = v
		elseif type(v) == "table" and type(into[k]) == "table" and next(v) ~= nil then
			fillDefaults(into[k], v)
		end
	end
	return into
end

function DataService.Get(player: Player)
	return DataService.Profiles[player]
end

function DataService.Rt(player: Player)
	return DataService.Runtime[player]
end

function DataService.Ready()
	local list = {}
	for player in DataService.Profiles do
		table.insert(list, player)
	end
	return list
end

function DataService.Bump(player: Player, stat: string, n: number?)
	local p = DataService.Profiles[player]
	if p then
		p.Stats[stat] = (p.Stats[stat] or 0) + (n or 1)
		GameSignals.Emit("Stat", player, stat, n or 1)
	end
end

function DataService.AddStateField(fn)
	table.insert(DataService.StateFields, fn)
end

function DataService.BuildState(player: Player)
	local p, rt = DataService.Profiles[player], DataService.Runtime[player]
	local state = {}
	for _, fn in DataService.StateFields do
		local ok, err = pcall(fn, player, state, p, rt)
		if not ok then
			warn("State field: " .. tostring(err))
		end
	end
	return state
end

local function load(player: Player)
	local data
	if store then
		local ok, result = pcall(function()
			return store:GetAsync(tostring(player.UserId))
		end)
		if ok then
			data = result
		end
	end
	if not player.Parent then
		return
	end
	DataService.Profiles[player] = fillDefaults(data or {}, defaultProfile())
	DataService.Runtime[player] = { Carrying = {}, Rot = 0, Buffs = {}, Bank = 0, Stunned = false }
	GameSignals.Emit("PlayerReady", player)
end

local function save(player: Player)
	local p = DataService.Profiles[player]
	if not (p and store) then
		return
	end
	p.LastSeen = os.time()
	pcall(function()
		store:SetAsync(tostring(player.UserId), p)
	end)
end

function DataService.Start()
	Players.PlayerRemoving:Connect(function(player)
		if DataService.Profiles[player] then
			GameSignals.Emit("PlayerLeaving", player)
			save(player)
		end
		DataService.Profiles[player] = nil
		DataService.Runtime[player] = nil
	end)
	game:BindToClose(function()
		for player in DataService.Profiles do
			save(player)
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.5)
			for player in DataService.Profiles do
				Remotes.Fire("State", player, DataService.BuildState(player))
			end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(90)
			for player in DataService.Profiles do
				task.spawn(save, player)
			end
		end
	end)
end

function DataService.Begin()
	Players.PlayerAdded:Connect(load)
	for _, player in Players:GetPlayers() do
		task.spawn(load, player)
	end
end

return DataService
