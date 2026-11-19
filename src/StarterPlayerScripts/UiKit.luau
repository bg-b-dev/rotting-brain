local Players = game:GetService("Players")

local UiKit = {}

UiKit.Colors = {
	Panel = Color3.fromRGB(32, 12, 44), PanelLight = Color3.fromRGB(58, 24, 78), Pink = Color3.fromRGB(255, 158, 199),
	Goo = Color3.fromRGB(130, 255, 80), Cyan = Color3.fromRGB(70, 225, 255), Yellow = Color3.fromRGB(255, 215, 70),
	Red = Color3.fromRGB(255, 80, 90), White = Color3.new(1, 1, 1), Gray = Color3.fromRGB(170, 160, 180),
}
local C = UiKit.Colors

local scales = {}

local function viewport()
	local vp = workspace.CurrentCamera.ViewportSize
	if workspace:GetAttribute("Capture16x9") then
		return Vector2.new(vp.X, math.min(vp.Y, vp.X * 9 / 16))
	end
	return vp
end

local function updateScales()
	local vp = viewport()
	local s = math.clamp(math.min(vp.X / 1280, vp.Y / 720), 0.5, 1.4)
	for _, uiScale in scales do
		uiScale.Scale = s
	end
end

function UiKit.Screen(name: string, order: number?)
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = order or 1
	local root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundTransparency = 1
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Parent = gui
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = root
	table.insert(scales, uiScale)
	local function fit()
		local vp = viewport()
		updateScales()
		root.Size = UDim2.fromOffset(vp.X / uiScale.Scale, vp.Y / uiScale.Scale)
	end
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
	workspace:GetAttributeChangedSignal("Capture16x9"):Connect(fit)
	fit()
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	return gui, root
end

function UiKit.Frame(parent: Instance, props)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = C.Panel
	f.BackgroundTransparency = 0.15
	f.BorderSizePixel = 0
	for k, v in props do
		if k ~= "Corner" and k ~= "Stroke" then
			f[k] = v
		end
	end
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, props.Corner or 10)
	if props.Stroke then
		local s = Instance.new("UIStroke")
		s.Color = props.Stroke
		s.Thickness = 2
		s.Parent = f
	end
	f.Parent = parent
	return f
end

function UiKit.Label(parent: Instance, props)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne
	t.TextColor3 = C.White
	t.TextStrokeTransparency = 0.5
	t.TextScaled = true
	for k, v in props do
		t[k] = v
	end
	t.Parent = parent
	return t
end

function UiKit.Button(parent: Instance, text: string, props, onClick)
	local b = Instance.new("TextButton")
	b.Font = Enum.Font.FredokaOne
	b.Text = text
	b.TextScaled = true
	b.TextColor3 = C.White
	b.BackgroundColor3 = C.PanelLight
	b.AutoButtonColor = true
	b.BorderSizePixel = 0
	for k, v in props do
		b[k] = v
	end
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 4)
	pad.PaddingLeft = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 6)
	pad.Parent = b
	if onClick then
		b.Activated:Connect(onClick)
	end
	b.Parent = parent
	return b
end

local windowsRoot
local openWindow
local openHooks = {}

function UiKit.Window(name: string, title: string, size: Vector2, accent: Color3?)
	if not windowsRoot then
		local _, root = UiKit.Screen("Windows", 5)
		windowsRoot = root
	end
	local w = UiKit.Frame(windowsRoot, {
		Name = name, Size = UDim2.fromOffset(size.X, size.Y), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 10), Visible = false, BackgroundTransparency = 0.05, Stroke = accent or C.Pink, Corner = 14,
	})
	UiKit.Label(w, { Name = "Title", Text = title, Size = UDim2.new(1, -80, 0, 40), Position = UDim2.fromOffset(16, 8), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = accent or C.Pink })
	UiKit.Button(w, "X", { Size = UDim2.fromOffset(40, 40), Position = UDim2.new(1, -50, 0, 8), BackgroundColor3 = C.Red }, function()
		UiKit.Close(w)
	end)
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Position = UDim2.fromOffset(16, 56)
	content.Size = UDim2.new(1, -32, 1, -68)
	content.Parent = w
	return w, content
end

function UiKit.Open(w)
	if openWindow and openWindow ~= w then
		openWindow.Visible = false
	end
	w.Visible = true
	openWindow = w
	if openHooks[w] then
		task.spawn(openHooks[w])
	end
end

function UiKit.OnOpen(w, fn)
	openHooks[w] = fn
end

function UiKit.Close(w)
	w.Visible = false
	if openWindow == w then
		openWindow = nil
	end
end

function UiKit.Toggle(w)
	if w.Visible then
		UiKit.Close(w)
	else
		UiKit.Open(w)
	end
end

function UiKit.Grid(parent: Instance, cell: Vector2, padding: number?)
	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.ScrollBarThickness = 8
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(cell.X, cell.Y)
	grid.CellPadding = UDim2.fromOffset(padding or 8, padding or 8)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = scroll
	scroll.Parent = parent
	return scroll
end

function UiKit.Viewport(parent: Instance, entry, props)
	local BrainrotModelKit = require(game:GetService("ReplicatedStorage").BrainrotModelKit)
	local vp = Instance.new("ViewportFrame")
	vp.BackgroundTransparency = 1
	vp.Ambient = Color3.fromRGB(210, 200, 210)
	vp.LightColor = Color3.new(1, 1, 1)
	vp.LightDirection = Vector3.new(-0.3, -1, 0.6)
	for k, v in props or {} do
		vp[k] = v
	end
	local model = BrainrotModelKit.Build(entry, { tag = false, fx = false })
	model:PivotTo(CFrame.new())
	model.Parent = vp
	local cf, size = model:GetBoundingBox()
	local cam = Instance.new("Camera")
	cam.FieldOfView = 40
	cam.CFrame = CFrame.lookAt(cf.Position + Vector3.new(size.X * 0.2, size.Y * 0.15, -math.max(size.X, size.Y, size.Z) * 1.55), cf.Position)
	cam.Parent = vp
	vp.CurrentCamera = cam
	vp.Parent = parent
	return vp, model
end

return UiKit
