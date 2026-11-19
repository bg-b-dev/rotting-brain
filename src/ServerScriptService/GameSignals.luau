local GameSignals = {}

local listeners = {}

function GameSignals.On(name: string, fn)
	listeners[name] = listeners[name] or {}
	table.insert(listeners[name], fn)
end

function GameSignals.Emit(name: string, ...)
	for _, fn in listeners[name] or {} do
		local ok, err = pcall(fn, ...)
		if not ok then
			warn("GameSignals " .. name .. ": " .. tostring(err))
		end
	end
end

return GameSignals
