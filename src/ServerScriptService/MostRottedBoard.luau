local RS = game:GetService("ReplicatedStorage")
local NumberFormat = require(RS.NumberFormat)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)

local MostRottedBoard = { Extra = {} }

local function column(parent, title, x)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Position = UDim2.fromScale(x, 0.16)
	frame.Size = UDim2.fromScale(0.48, 0.82)
	frame.Parent = parent
	local head = Instance.new("TextLabel")
	head.Size = UDim2.fromScale(1, 0.1)
	head.BackgroundTransparency = 1
	head.Font = Enum.Font.FredokaOne
	head.TextScaled = true
	head.TextColor3 = Color3.fromRGB(255, 215, 70)
	head.Text = title
	head.Parent = frame
	local rows = {}
	for i = 1, 10 do
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 0.085)
		t.Position = UDim2.fromScale(0, 0.11 + (i - 1) * 0.089)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.FredokaOne
		t.TextScaled = true
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.TextColor3 = i == 1 and Color3.fromRGB(130, 255, 80) or Color3.new(1, 1, 1)
		t.Text = ""
		t.Parent = frame
		rows[i] = t
	end
	return rows
end

local function fill(rows, list, field, fmt)
	table.sort(list, function(a, b)
		return a[field] > b[field]
	end)
	for i, row in rows do
		local e = list[i]
		row.Text = e and (i .. ". " .. e.Name .. "  " .. fmt(e[field])) or ""
	end
end

function MostRottedBoard.Start()
	local screen = workspace.BrainWorld.MostRottedBoard.Screen
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Leaderboard"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = screen
	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(20, 6, 28)
	bg.Parent = gui
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 0.14)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.LuckiestGuy
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(255, 158, 199)
	title.Text = "🏆 MOST ROTTED 🏆"
	title.Parent = bg
	local richRows = column(bg, "🧠 BIGGEST BRAINS", 0.02)
	local pediaRows = column(bg, "📖 BRAINPEDIA", 0.5)
	task.spawn(function()
		while true do
			local list = {}
			for _, player in DataService.Ready() do
				local p = DataService.Get(player)
				table.insert(list, { Name = player.DisplayName, Cells = p.TotalEarned, Found = Economy.FoundCount(p) })
			end
			for _, e in MostRottedBoard.Extra do
				table.insert(list, e)
			end
			fill(richRows, table.clone(list), "Cells", NumberFormat.Cells)
			fill(pediaRows, table.clone(list), "Found", function(n)
				return n .. "/60"
			end)
			task.wait(5)
		end
	end)
end

return MostRottedBoard
