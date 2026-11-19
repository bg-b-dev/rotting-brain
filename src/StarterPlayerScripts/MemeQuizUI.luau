local RS = game:GetService("ReplicatedStorage")
local BrainrotCatalog = require(RS.BrainrotCatalog)
local RarityConfig = require(RS.RarityConfig)
local Remotes = require(RS.Remotes)
local UiKit = require(script.Parent.UiKit)

local C = UiKit.Colors

local MemeQuizUI = {}

function MemeQuizUI.Start()
	local win, content = UiKit.Window("MemeQuiz", "❓ MEME QUIZ", Vector2.new(560, 560), C.Yellow)
	local question = UiKit.Label(content, { Size = UDim2.new(1, 0, 0, 34), Text = "", TextColor3 = C.Yellow })
	local timer = UiKit.Label(content, { Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, 36), Text = "", TextColor3 = C.Red })
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.fromOffset(0, 64)
	holder.Size = UDim2.new(1, 0, 1, -64)
	holder.Parent = content
	local grid = UiKit.Grid(holder, Vector2.new(164, 132), 10)
	local round = 0
	Remotes.Get("Quiz").OnClientEvent:Connect(function(quiz)
		round += 1
		local myRound = round
		for _, c in grid:GetChildren() do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		question.Text = "WHICH ONE IS " .. string.upper(quiz.Name) .. "?"
		for _, id in quiz.Options do
			local def = BrainrotCatalog.Get(id)
			local tile = UiKit.Frame(grid, { BackgroundColor3 = C.PanelLight, Stroke = RarityConfig.ByName[def.Rarity].Color })
			UiKit.Viewport(tile, { Id = id, Lv = 1 }, { Size = UDim2.fromScale(1, 1) })
			UiKit.Button(tile, "", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, function()
				Remotes.Send("QuizAnswer", id)
				UiKit.Close(win)
			end)
		end
		UiKit.Open(win)
		for left = quiz.Seconds, 0, -1 do
			if myRound ~= round or not win.Visible then
				return
			end
			timer.Text = left .. "s"
			task.wait(1)
		end
		if myRound == round and win.Visible then
			Remotes.Send("QuizAnswer", 0)
			UiKit.Close(win)
		end
	end)
end

return MemeQuizUI
