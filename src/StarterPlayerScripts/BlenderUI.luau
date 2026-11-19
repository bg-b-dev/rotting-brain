local RS = game:GetService("ReplicatedStorage")
local BrainrotCatalog = require(RS.BrainrotCatalog)
local RarityConfig = require(RS.RarityConfig)
local NumberFormat = require(RS.NumberFormat)
local Remotes = require(RS.Remotes)
local UiKit = require(script.Parent.UiKit)
local ClientState = require(script.Parent.ClientState)
local InputController = require(script.Parent.InputController)

local C = UiKit.Colors

local BlenderUI = {}

function BlenderUI.Start()
	local win, content = UiKit.Window("Blender", "🍝 MEME BLENDER · 3 IN, 1 STRONGER OUT", Vector2.new(720, 440), C.Goo)
	local status = UiKit.Label(content, { Size = UDim2.new(1, 0, 0, 28), Text = "", TextColor3 = C.Goo, TextXAlignment = Enum.TextXAlignment.Left })
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.fromOffset(0, 36)
	holder.Size = UDim2.new(1, 0, 1, -36)
	holder.Parent = content
	local grid = UiKit.Grid(holder, Vector2.new(160, 200), 10)
	local shownKey = ""

	local function render(s)
		if not win.Visible then
			return
		end
		if s.BlendJob then
			status.Text = "BLENDING " .. s.BlendJob.Name .. "... " .. NumberFormat.Clock(s.BlendJob.Left)
		elseif not s.NearBlender then
			status.Text = "Walk to the MEME KITCHEN to blend. 3 copies → +1 Lv, maybe a mutation. Lv 5 = sure mutation."
		else
			status.Text = "Pick a brainrot with 3 copies on your Lobe. +1 Lv, chance of a mutation."
		end
		local key = ""
		for _, o in s.BlendOptions or {} do
			key ..= o.Id .. ":" .. o.Count .. ":" .. o.MaxLv .. ","
		end
		if key == shownKey then
			return
		end
		shownKey = key
		for _, c in grid:GetChildren() do
			if c:IsA("Frame") then
				c:Destroy()
			end
		end
		if #(s.BlendOptions or {}) == 0 then
			local empty = UiKit.Frame(grid, { BackgroundColor3 = C.PanelLight })
			UiKit.Label(empty, { Size = UDim2.new(1, -16, 1, -16), Position = UDim2.fromOffset(8, 8), Text = "No triples yet. Buy 3 of the same meme!", TextWrapped = true, TextColor3 = C.Gray })
		end
		for _, o in s.BlendOptions or {} do
			local def = BrainrotCatalog.Get(o.Id)
			local card = UiKit.Frame(grid, { BackgroundColor3 = C.PanelLight, Stroke = RarityConfig.ByName[def.Rarity].Color })
			UiKit.Viewport(card, { Id = o.Id, Lv = o.MaxLv }, { Size = UDim2.new(1, 0, 0, 90) })
			UiKit.Label(card, { Size = UDim2.new(1, -10, 0, 22), Position = UDim2.fromOffset(5, 92), Text = def.Name })
			UiKit.Label(card, { Size = UDim2.new(1, -10, 0, 20), Position = UDim2.fromOffset(5, 116), Text = "x" .. o.Count .. " owned · best Lv " .. o.MaxLv, TextColor3 = C.Gray })
			UiKit.Button(card, o.MaxLv >= 5 and "BLEND ✨" or "BLEND 3", { Size = UDim2.new(1, -16, 0, 44), Position = UDim2.fromOffset(8, 146), BackgroundColor3 = Color3.fromRGB(60, 150, 50) }, function()
				Remotes.Send("Blend", o.Id)
			end)
		end
	end
	ClientState.Changed.Event:Connect(render)
	UiKit.OnOpen(win, function()
		shownKey = "?"
		render(ClientState.State)
	end)
	InputController.Register("G", function()
		UiKit.Toggle(win)
	end)
end

return BlenderUI
