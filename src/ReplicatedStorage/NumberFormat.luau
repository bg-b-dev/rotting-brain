local NumberFormat = {}

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi" }

function NumberFormat.Short(n: number): string
	n = math.floor(n)
	local i = 1
	local v = math.abs(n)
	while v >= 1000 and i < #SUFFIXES do
		v /= 1000
		i += 1
	end
	if i == 1 then
		return tostring(n)
	end
	local s = v >= 100 and string.format("%d", v) or string.format("%.1f", v):gsub("%.0$", "")
	return (n < 0 and "-" or "") .. s .. SUFFIXES[i]
end

function NumberFormat.Cells(n: number): string
	return "🧠" .. NumberFormat.Short(n)
end

function NumberFormat.Clock(seconds: number): string
	seconds = math.max(0, math.ceil(seconds))
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

return NumberFormat
