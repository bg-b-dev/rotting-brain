local UpgradeConfig = {}

UpgradeConfig.MaxTier = 10

UpgradeConfig.Groups = {
	{ Id = "Income", Icon = "🧠", Effect = "+10% income from all Lobes", Base = 400, Growth = 4 },
	{ Id = "Speed", Icon = "👟", Effect = "+5% walk speed, faster carry", Base = 250, Growth = 3.6 },
	{ Id = "Luck", Icon = "🍀", Effect = "+5% rarity and mutation luck on the belt", Base = 900, Growth = 4.2 },
	{ Id = "Defense", Icon = "🛡️", Effect = "+6s Mind Block, stronger Brain Fog", Base = 700, Growth = 4 },
	{ Id = "Thoughts", Icon = "💭", Effect = "-6% Thought Bubble time, +1 pad at Lv 5 and 10", Base = 1200, Growth = 4 },
}

function UpgradeConfig.Cost(groupId: string, nextTier: number)
	for _, g in UpgradeConfig.Groups do
		if g.Id == groupId then
			return math.floor(g.Base * g.Growth ^ (nextTier - 1))
		end
	end
	return math.huge
end

UpgradeConfig.Washes = {
	{ Cost = 1e6, Mult = 1.5, Unlock = "Gold Thought Bubbles" },
	{ Cost = 25e6, Mult = 2, Unlock = "Blender level 2" },
	{ Cost = 5e8, Mult = 3, Unlock = "Galaxy Thought Bubbles" },
	{ Cost = 1e10, Mult = 4.5, Unlock = "Lobe LV 5" },
	{ Cost = 2.5e11, Mult = 6, Unlock = "Deep Subconscious" },
}

UpgradeConfig.Perks = {
	{ Id = "ExtraCarry", Name = "+1 Carry", Cost = 1, Text = "Carry 2 brainrots at once" },
	{ Id = "Luck", Name = "+10% Luck", Cost = 1, Text = "Better belt rarities forever" },
	{ Id = "HeadStart", Name = "Head Start", Cost = 1, Text = "Every Brain Wash starts with 🧠10K" },
	{ Id = "Income", Name = "+25% Income", Cost = 2, Text = "All Lobes pay more" },
	{ Id = "FastBubbles", Name = "Fast Thoughts", Cost = 2, Text = "Thought Bubbles pop 20% faster" },
}

return UpgradeConfig
