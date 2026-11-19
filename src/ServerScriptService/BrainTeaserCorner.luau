local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local BrainrotCatalog = require(RS.BrainrotCatalog)
local NumberFormat = require(RS.NumberFormat)
local Remotes = require(RS.Remotes)
local DataService = require(script.Parent.DataService)
local Economy = require(script.Parent.BrainCellEconomy)
local HudNotify = require(script.Parent.HudNotify)

local BrainTeaserCorner = { Quizzes = {}, Runs = {} }

local QUIZ_SECONDS = 10
local QUIZ_COOLDOWN = 20
local rng = Random.new()

function BrainTeaserCorner.StartQuiz(player: Player)
	local q = BrainTeaserCorner.Quizzes[player]
	if q and os.clock() < q.NextAt then
		HudNotify.PopupOver(player, "QUIZ COOLDOWN", Color3.fromRGB(200, 200, 200))
		return
	end
	local ids = {}
	while #ids < 9 do
		local id = rng:NextInteger(1, #BrainrotCatalog.List)
		if not table.find(ids, id) then
			table.insert(ids, id)
		end
	end
	local answer = ids[rng:NextInteger(1, 9)]
	BrainTeaserCorner.Quizzes[player] = { Answer = answer, EndsAt = os.clock() + QUIZ_SECONDS, NextAt = os.clock() + QUIZ_COOLDOWN }
	Remotes.Fire("Quiz", player, { Name = BrainrotCatalog.Get(answer).Name, Options = ids, Seconds = QUIZ_SECONDS })
end

function BrainTeaserCorner.Answer(player: Player, id: number)
	local q = BrainTeaserCorner.Quizzes[player]
	if not q or not q.Answer then
		return
	end
	local answer = q.Answer
	q.Answer = nil
	if id == answer and os.clock() <= q.EndsAt then
		local prize = math.floor(math.max(1000, Economy.Cps(player) * 30))
		Economy.Add(player, prize)
		Economy.AddBuff(player, "Sigma Mindset", 45)
		DataService.Bump(player, "QuizWins", 1)
		HudNotify.PopupOver(player, "BIG BRAIN! +" .. NumberFormat.Cells(prize), Color3.fromRGB(130, 255, 80), true)
	else
		HudNotify.PopupOver(player, "WRONG! IT WAS " .. string.upper(BrainrotCatalog.Get(answer).Name), Color3.fromRGB(255, 90, 90), true)
	end
end

local function startDodge(player)
	BrainTeaserCorner.Runs[player] = os.clock()
	HudNotify.PopupOver(player, "GO! DON'T TOUCH GRASS", Color3.fromRGB(130, 255, 80), true)
end

function BrainTeaserCorner.Start()
	local corner = workspace.BrainWorld.BrainTeaserCorner
	local track = corner.GrassDodge
	corner.QuizWall.Prompt.Triggered:Connect(BrainTeaserCorner.StartQuiz)
	Remotes.OnRequest("QuizAnswer", BrainTeaserCorner.Answer)
	local blades = {}
	for _, b in track:GetChildren() do
		if b.Name == "GrassBlade" then
			table.insert(blades, { Part = b, Base = b.Position, Phase = b:GetAttribute("Phase") })
		end
	end
	local startPad, finishPad = track.StartPad, track.FinishPad
	task.spawn(function()
		while true do
			local t = os.clock()
			for _, b in blades do
				b.Up = math.sin(t * 2.2 + b.Phase) > -0.1
				b.Part.Position = b.Base + Vector3.new(0, b.Up and 0 or -5.5, 0)
			end
			for _, player in Players:GetPlayers() do
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if root and DataService.Get(player) then
					local pos = root.Position
					local started = BrainTeaserCorner.Runs[player]
					if not started and (pos - startPad.Position).Magnitude < 4.5 then
						startDodge(player)
					elseif started then
						if (pos - finishPad.Position).Magnitude < 4.5 then
							local time = os.clock() - started
							BrainTeaserCorner.Runs[player] = nil
							local prize = math.floor(math.max(500, Economy.Cps(player) * 20) * (time < 8 and 3 or time < 12 and 2 or 1))
							Economy.Add(player, prize)
							DataService.Bump(player, "DodgeRuns", 1)
							HudNotify.PopupOver(player, string.format("%.1fs! +%s", time, NumberFormat.Cells(prize)), Color3.fromRGB(255, 215, 70), true)
						elseif (pos - startPad.Position).Magnitude > 70 then
							BrainTeaserCorner.Runs[player] = nil
						else
							for _, b in blades do
								local d = pos - b.Part.Position
								if b.Up and math.abs(d.X) < 1.6 and math.abs(d.Z) < 4.5 and pos.Y < 8 then
									BrainTeaserCorner.Runs[player] = nil
									player.Character:PivotTo(startPad.CFrame + Vector3.new(-4, 4, 0))
									HudNotify.PopupOver(player, "TOUCHED GRASS! RESET", Color3.fromRGB(90, 220, 90), true)
									break
								end
							end
						end
					end
				end
			end
			task.wait(0.05)
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		BrainTeaserCorner.Quizzes[player] = nil
		BrainTeaserCorner.Runs[player] = nil
	end)
end

return BrainTeaserCorner
