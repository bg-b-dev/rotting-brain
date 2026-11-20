local TweenService = game:GetService("TweenService")
local Remotes = require(game:GetService("ReplicatedStorage").Remotes)

local MemePopups = {}

function MemePopups.Show(text: string, color: Color3, position: Vector3, big: boolean?)
	local camera = workspace.CurrentCamera
	if (camera.CFrame.Position - position).Magnitude > 140 then
		return
	end
	local att = Instance.new("Attachment")
	att.WorldPosition = position
	att.Parent = workspace.Terrain
	local bb = Instance.new("BillboardGui")
	bb.Adornee = att
	bb.AlwaysOnTop = false
	bb.LightInfluence = 0
	bb.Size = big and UDim2.fromScale(20, 4.6) or UDim2.fromScale(11, 2.6)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextScaled = true
	t.Font = Enum.Font.LuckiestGuy
	t.TextColor3 = color
	t.TextStrokeTransparency = 0
	t.Rotation = math.random(-8, 8)
	t.Parent = bb
	bb.Parent = att
	local info = TweenInfo.new(big and 1.8 or 1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(bb, info, { StudsOffsetWorldSpace = Vector3.new(0, big and 6 or 4, 0) }):Play()
	TweenService:Create(t, info, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(info.Time, function()
		bb:Destroy()
		att:Destroy()
	end)
end

function MemePopups.Start()
	Remotes.Get("Popup").OnClientEvent:Connect(MemePopups.Show)
end

return MemePopups
