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
