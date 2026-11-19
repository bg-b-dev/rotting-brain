local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local NAMES = { "Request", "State", "Pedia", "Popup", "Feed", "CatchCard", "OpenUI", "Quiz", "Spin" }

local folder
if RunService:IsServer() then
	folder = ReplicatedStorage:FindFirstChild("RemoteEvents") or Instance.new("Folder")
	folder.Name = "RemoteEvents"
	for _, name in NAMES do
		if not folder:FindFirstChild(name) then
			Instance.new("RemoteEvent", folder).Name = name
		end
	end
	folder.Parent = ReplicatedStorage
else
	folder = ReplicatedStorage:WaitForChild("RemoteEvents")
end

function Remotes.Get(name: string): RemoteEvent
	return folder:WaitForChild(name)
end

local handlers = {}
function Remotes.OnRequest(action: string, fn)
	handlers[action] = fn
end

if RunService:IsServer() then
	folder.Request.OnServerEvent:Connect(function(player, action, ...)
		local fn = handlers[action]
		if fn then
			local ok, err = pcall(fn, player, ...)
			if not ok then
				warn("Request " .. tostring(action) .. " failed: " .. tostring(err))
			end
		end
	end)
end

function Remotes.Fire(name: string, player: Player, ...)
	folder[name]:FireClient(player, ...)
end

function Remotes.FireAll(name: string, ...)
	folder[name]:FireAllClients(...)
end

function Remotes.Send(action: string, ...)
	folder.Request:FireServer(action, ...)
end

return Remotes
