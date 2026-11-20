local RS = game:GetService("ReplicatedStorage")
local BrainrotCatalog = require(RS.BrainrotCatalog)
local RarityConfig = require(RS.RarityConfig)
local MutationConfig = require(RS.MutationConfig)
local NumberFormat = require(RS.NumberFormat)
local UiKit = require(script.Parent.UiKit)
local ClientState = require(script.Parent.ClientState)
local InputController = require(script.Parent.InputController)

local C = UiKit.Colors

local BrainpediaUI = {}

local tiles = {}

function BrainpediaUI.Start()
	local win, content = UiKit.Window("Brainpedia", "📖 BRAINPEDIA", Vector2.new(1240, 680), C.Pink)
	local header = UiKit.Label(content, { Size = UDim2.fromOffset(330, 44), Text = "", TextColor3 = C.Yellow, Font = Enum.Font.LuckiestGuy, TextXAlignment = Enum.TextXAlignment.Left })
	local subHeader = UiKit.Label(content, { Size = UDim2.new(1, -350, 0, 26), Position = UDim2.fromOffset(350, 10), Text = "", TextColor3 = C.Pink, TextXAlignment = Enum.TextXAlignment.Right })
	local gridHolder = Instance.new("Frame")
	gridHolder.BackgroundTransparency = 1
	gridHolder.Position = UDim2.fromOffset(0, 52)
	gridHolder.Size = UDim2.new(1, 0, 1, -94)
	gridHolder.Parent = content
	local grid = UiKit.Grid(gridHolder, Vector2.new(94, 98), 6)
	local info = UiKit.Frame(content, { Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 1, -36), BackgroundColor3 = C.PanelLight, Stroke = C.Pink })
	local infoText = UiKit.Label(info, { Size = UDim2.new(1, -20, 1, -8), Position = UDim2.fromOffset(10, 4), Text = "Hover a tile. Every 10 found = +10% income. 60 found = income x2.", TextWrapped = true })
	local built = false

	local function buildTiles()
		built = true
		for _, def in BrainrotCatalog.List do
			local rarity = RarityConfig.ByName[def.Rarity]
			local tile = UiKit.Frame(grid, { LayoutOrder = def.Id, BackgroundColor3 = C.Panel, Stroke = rarity.Color, Corner = 8 })
			local vp = UiKit.Viewport(tile, { Id = def.Id, Lv = 1 }, { Size = UDim2.new(1, 0, 0, 56) })
			local name = UiKit.Label(tile, { Size = UDim2.new(1, -6, 0, 16), Position = UDim2.fromOffset(3, 56), Text = def.Name, TextColor3 = rarity.Color })
			local status = UiKit.Label(tile, { Size = UDim2.new(1, -6, 0, 14), Position = UDim2.fromOffset(3, 73), Text = "", TextColor3 = C.Goo })
			local badge = UiKit.Label(tile, { Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -22, 0, 2), Text = "🔒" })
			local dots = {}
			for i, mut in MutationConfig.List do
				dots[mut.Name] = UiKit.Frame(tile, { Size = UDim2.fromOffset(7, 7), Position = UDim2.fromOffset(11 + (i - 1) * 9, 89), BackgroundColor3 = mut.Color, BackgroundTransparency = 0.85, Corner = 4 })
			end
			local hover = Instance.new("TextButton")
			hover.BackgroundTransparency = 1
			hover.Text = ""
			hover.Size = UDim2.fromScale(1, 1)
			hover.Parent = tile
			hover.MouseEnter:Connect(function()
				local found = ClientState.Pedia[tostring(def.Id)]
				if found then
					infoText.Text = def.Name .. " · " .. def.Rarity .. " · " .. NumberFormat.Cells(def.Income) .. "/s · \"" .. def.Caption .. "\""
				else
					infoText.Text = def.Name .. " · " .. def.Rarity .. " · 🔒 NOT FOUND. Keep rotting."
				end
			end)
			tiles[def.Id] = { Viewport = vp, Name = name, Status = status, Badge = badge, Dots = dots, Def = def }
		end
	end

	local function render()
		if not win.Visible then
			return
		end
		if not built then
			buildTiles()
		end
		local found = 0
		for id, tile in tiles do
			local muts = ClientState.Pedia[tostring(id)]
			if muts then
				found += 1
			end
			tile.Viewport.ImageColor3 = muts and Color3.new(1, 1, 1) or Color3.fromRGB(120, 110, 125)
			tile.Viewport.ImageTransparency = muts and 0 or 0.45
			tile.Name.TextTransparency = muts and 0 or 0.35
			tile.Status.Text = muts and ("+" .. NumberFormat.Cells(tile.Def.Income) .. "/s") or "NOT FOUND"
			tile.Status.TextColor3 = muts and C.Goo or C.Gray
			tile.Badge.Text = muts and "✅" or "🔒"
			for mutName, dot in tile.Dots do
				dot.BackgroundTransparency = (muts and muts[mutName]) and 0 or 0.85
			end
		end
		local bonus = 10 * (found // 10)
		header.Text = "FOUND " .. found .. "/60"
		subHeader.Text = "8 RARITIES · 8 MUTATIONS · MILESTONE BONUS +" .. bonus .. "% INCOME" .. (found >= 60 and " · x2 COMPLETE!" or "")
	end
	ClientState.PediaChanged.Event:Connect(render)
	UiKit.OnOpen(win, render)
	InputController.Register("B", function()
		UiKit.Toggle(win)
	end)
end

return BrainpediaUI
