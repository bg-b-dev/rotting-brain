local RarityConfig = {}

RarityConfig.List = {
	{ Name = "Common", Color = Color3.fromRGB(200, 200, 210), Count = 12, Income = { 1, 12 }, PriceMult = 5, Weight = 60, Scale = 1 },
	{ Name = "Uncommon", Color = Color3.fromRGB(90, 225, 90), Count = 10, Income = { 15, 90 }, PriceMult = 7, Weight = 26, Scale = 1.1 },
	{ Name = "Rare", Color = Color3.fromRGB(70, 150, 255), Count = 9, Income = { 120, 800 }, PriceMult = 9, Weight = 9, Scale = 1.2 },
	{ Name = "Epic", Color = Color3.fromRGB(175, 85, 255), Count = 8, Income = { 1e3, 6e3 }, PriceMult = 12, Weight = 3.5, Scale = 1.35 },
	{ Name = "Legendary", Color = Color3.fromRGB(255, 150, 30), Count = 7, Income = { 1e4, 6e4 }, PriceMult = 15, Weight = 1.1, Scale = 1.5 },
	{ Name = "Mythic", Color = Color3.fromRGB(255, 90, 190), Count = 6, Income = { 1e5, 5e5 }, PriceMult = 19, Weight = 0.3, Scale = 1.7 },
	{ Name = "Brainrot God", Color = Color3.fromRGB(255, 215, 60), Count = 5, Income = { 1e6, 4e6 }, PriceMult = 24, Weight = 0.06, Scale = 2.0 },
	{ Name = "Fully Rotted", Color = Color3.fromRGB(120, 255, 60), Count = 3, Income = { 1e7, 2.5e7 }, PriceMult = 30, Weight = 0, Scale = 2.4 },
}

RarityConfig.ByName = {}
for i, r in RarityConfig.List do
	r.Index = i
	RarityConfig.ByName[r.Name] = r
end

function RarityConfig.Roll(rng: Random, luck: number, minIndex: number?)
	local total = 0
	local weights = {}
	for i, r in RarityConfig.List do
		local w = (minIndex and i < minIndex) and 0 or r.Weight * (1 + luck) ^ (i - 1)
		weights[i] = w
		total += w
	end
	local pick = rng:NextNumber() * total
	for i, w in weights do
		pick -= w
		if pick <= 0 then
			return RarityConfig.List[i]
		end
	end
	return RarityConfig.List[1]
end

return RarityConfig
