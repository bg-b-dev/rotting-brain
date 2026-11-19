local MutationConfig = {}

MutationConfig.List = {
	{ Name = "Rotten", Mult = 2, Color = Color3.fromRGB(110, 255, 70), Weight = 30, Popup = "EWW, ROTTEN!" },
	{ Name = "Golden", Mult = 3, Color = Color3.fromRGB(255, 200, 40), Weight = 22, Popup = "GOLDEN!" },
	{ Name = "Rizzed", Mult = 4, Color = Color3.fromRGB(255, 110, 200), Weight = 16, Popup = "RIZZED!" },
	{ Name = "Galaxy Brain", Mult = 5, Color = Color3.fromRGB(150, 90, 255), Weight = 11, Popup = "GALAXY BRAIN!" },
	{ Name = "Brain Freeze", Mult = 6, Color = Color3.fromRGB(150, 230, 255), Weight = 8, Popup = "BRAIN FREEZE!" },
	{ Name = "Sigma", Mult = 7, Color = Color3.fromRGB(255, 205, 60), Weight = 6, Popup = "SIGMA!" },
	{ Name = "Ohio", Mult = 8, Color = Color3.fromRGB(255, 60, 60), Weight = 4, Popup = "ONLY IN OHIO!" },
	{ Name = "Max Aura", Mult = 10, Color = Color3.fromRGB(255, 255, 255), Weight = 3, Popup = "+∞ AURA" },
}
MutationConfig.BaseChance = 0.06

MutationConfig.ByName = {}
for i, m in MutationConfig.List do
	m.Index = i
	MutationConfig.ByName[m.Name] = m
end

function MutationConfig.Mult(name: string?)
	local m = name and MutationConfig.ByName[name]
	return m and m.Mult or 1
end

function MutationConfig.Roll(rng: Random, luck: number, forced: boolean?)
	if not forced and rng:NextNumber() > MutationConfig.BaseChance * (1 + luck) then
		return nil
	end
	local total = 0
	for i, m in MutationConfig.List do
		total += m.Weight * (1 + luck * 0.5) ^ (i - 1)
	end
	local pick = rng:NextNumber() * total
	for i, m in MutationConfig.List do
		pick -= m.Weight * (1 + luck * 0.5) ^ (i - 1)
		if pick <= 0 then
			return m.Name
		end
	end
	return "Rotten"
end

return MutationConfig
