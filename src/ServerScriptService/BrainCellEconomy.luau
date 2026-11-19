local RS = game:GetService("ReplicatedStorage")
local BrainrotModelKit = require(RS.BrainrotModelKit)
local NumberFormat = require(RS.NumberFormat)
local DataService = require(script.Parent.DataService)
local GameSignals = require(script.Parent.GameSignals)
local HudNotify = require(script.Parent.HudNotify)

local BrainCellEconomy = { GlobalIncomeMult = 1 }

BrainCellEconomy.WashMult = { [0] = 1, 1.5, 2, 3, 4.5, 6 }

local BUFF_INCOME = { ["Fully Rotted"] = 3 }
local BUFF_LUCK = { ["Sigma Mindset"] = 0.5, ["Energy Drink"] = 0.15 }

function BrainCellEconomy.AddBuff(player: Player, name: string, seconds: number)
	local rt = DataService.Rt(player)
	if rt then
		rt.Buffs[name] = math.max(rt.Buffs[name] or 0, os.clock()) + seconds
	end
end

function BrainCellEconomy.HasBuff(player: Player, name: string)
	local rt = DataService.Rt(player)
	return rt ~= nil and (rt.Buffs[name] or 0) > os.clock()
end

function BrainCellEconomy.FoundCount(p)
	local n = 0
	for _ in p.Pedia do
		n += 1
	end
	return n
end

function BrainCellEconomy.Multiplier(player: Player)
	local p = DataService.Get(player)
	local found = BrainCellEconomy.FoundCount(p)
	local m = (1 + 0.1 * p.Upgrades.Income) * (BrainCellEconomy.WashMult[p.Washes] or 6) * (1 + 0.1 * (found // 10)) * (found >= 60 and 2 or 1)
	if p.Perks.Income then
		m *= 1.25
	end
	for name, k in BUFF_INCOME do
		if BrainCellEconomy.HasBuff(player, name) then
			m *= k
		end
	end
	return m * BrainCellEconomy.GlobalIncomeMult
end

function BrainCellEconomy.Luck(player: Player)
	local p = DataService.Get(player)
	local luck = 0.05 * p.Upgrades.Luck + (p.Perks.Luck and 0.1 or 0)
	for name, k in BUFF_LUCK do
		if BrainCellEconomy.HasBuff(player, name) then
			luck += k
		end
	end
	return luck
end

function BrainCellEconomy.BestLuck()
	local best = 0
	for _, player in DataService.Ready() do
		best = math.max(best, BrainCellEconomy.Luck(player))
	end
	return best
end

function BrainCellEconomy.BaseIncome(p)
	local sum = 0
	for _, entry in p.Podiums do
		sum += BrainrotModelKit.Income(entry)
	end
	return sum
end

function BrainCellEconomy.Cps(player: Player)
	return BrainCellEconomy.BaseIncome(DataService.Get(player)) * BrainCellEconomy.Multiplier(player)
end

function BrainCellEconomy.Add(player: Player, amount: number)
	local p = DataService.Get(player)
	if p then
		p.Cells += amount
		if amount > 0 then
			p.TotalEarned += amount
		end
	end
end

function BrainCellEconomy.TrySpend(player: Player, amount: number)
	local p = DataService.Get(player)
	if p and p.Cells >= amount then
		p.Cells -= amount
		return true
	end
	HudNotify.PopupOver(player, "NOT ENOUGH 🧠", Color3.fromRGB(255, 90, 90))
	return false
end

local function collect(player, lobe)
	local rt = DataService.Rt(player)
	if rt.Bank >= 1 then
		local amount = math.floor(rt.Bank)
		BrainCellEconomy.Add(player, amount)
		rt.Bank -= amount
		HudNotify.Popup(nil, "+" .. NumberFormat.Cells(amount), Color3.fromRGB(150, 255, 110), lobe.Model.CollectPad.Position + Vector3.new(0, 4, 0), true)
	end
end

function BrainCellEconomy.Start()
	local LobeService = require(script.Parent.LobeService)
	GameSignals.On("PlayerReady", function(player)
		local p = DataService.Get(player)
		if p.LastSeen > 0 and p.LastCps > 0 then
			local away = math.min(os.time() - p.LastSeen, 8 * 3600)
			local gain = math.floor(p.LastCps * away * 0.25)
			if gain > 0 then
				BrainCellEconomy.Add(player, gain)
				HudNotify.Feed(player, "😴 Offline earnings: +" .. NumberFormat.Cells(gain))
			end
		end
	end)
	DataService.AddStateField(function(player, s, p, rt)
		s.Cells = p.Cells
		s.Cps = BrainCellEconomy.Cps(player)
		s.Washes = p.Washes
		s.WashMult = BrainCellEconomy.WashMult[p.Washes] or 6
		s.Bank = rt.Bank
		s.Buffs = {}
		for name, t in rt.Buffs do
			if t > os.clock() then
				table.insert(s.Buffs, { Name = name, Left = t - os.clock() })
			end
		end
	end)
	local tick = 0
	task.spawn(function()
		while true do
			task.wait(1)
			tick += 1
			for _, player in DataService.Ready() do
				local p, rt = DataService.Get(player), DataService.Rt(player)
				local cps = BrainCellEconomy.Cps(player)
				p.LastCps = cps
				if p.Gear.RizzMagnet then
					BrainCellEconomy.Add(player, cps)
				else
					rt.Bank += cps
				end
				local lobe = LobeService.LobeOf(player)
				if lobe then
					lobe.Model.CollectPad.Bank.Text.Text = p.Gear.RizzMagnet and "🧲 RIZZ MAGNET ON" or ("COLLECT " .. NumberFormat.Cells(rt.Bank))
					if tick % 3 == 0 then
						local keys = {}
						for k in p.Podiums do
							table.insert(keys, k)
						end
						if #keys > 0 then
							local k = keys[math.random(1, #keys)]
							local model = lobe.Models[k]
							if model then
								local amount = BrainrotModelKit.Income(p.Podiums[k]) * BrainCellEconomy.Multiplier(player) * 3
								HudNotify.Popup(nil, "+" .. NumberFormat.Cells(amount), Color3.fromRGB(150, 255, 110), model:GetPivot().Position + Vector3.new(0, 7, 0), true)
							end
						end
					end
				end
			end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.25)
			for _, player in DataService.Ready() do
				local lobe = LobeService.LobeOf(player)
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if lobe and root and (root.Position - lobe.Model.CollectPad.Position).Magnitude < 5 then
					collect(player, lobe)
				end
			end
		end
	end)
end

return BrainCellEconomy
