local library = script.Parent.Parent.Library

local SelectorSystem = require(script.Parent.Selector)
local UserInterfaceSystem = require(script.Parent.UserInterface)
local MouseSystem = require(script.Parent.Mouse)

local Janitor = require(library.Janitor)
local SelectedJanitor = Janitor.new()
local PointJanitor = Janitor.new()
local Cleanup = Janitor.new()

local function setResizeDirection(x, y, object)
	local absX, absY = object.AbsolutePosition.X, object.AbsolutePosition.Y
	local absWidth, absHeight = object.AbsoluteSize.X, object.AbsoluteSize.Y
	local centerX, centerY = absX + absWidth / 2, absY + absHeight / 2

	if x < absX + 5 and y < absY + 5 then
		resizeDirection = "TopLeft"
	elseif x > absX + absWidth - 5 and y < absY + 5 then
		resizeDirection = "TopRight"
	elseif x < absX + 5 and y > absY + absHeight - 5 then
		resizeDirection = "BottomLeft"
	elseif x > absX + absWidth - 5 and y > absY + absHeight - 5 then
		resizeDirection = "BottomRight"
	elseif y < centerY - 5 then
		resizeDirection = "Top"
	elseif y > centerY + 5 then
		resizeDirection = "Bottom"
	elseif x < centerX - 5 then
		resizeDirection = "Left"
	elseif x > centerX + 5 then
		resizeDirection = "Right"
	else
		resizeDirection = ""
	end
end

local resizePointSize = Vector2.new(8, 8)

local function createResizePoint(name)
	local resizePoint = Instance.new("TextButton")
	resizePoint.Name = name
	resizePoint.AnchorPoint = Vector2.new(0.5, 0.5)
	resizePoint.BackgroundColor3 = Color3.new(0.941176, 0.078431, 0.078431)
	resizePoint.BorderSizePixel = 0
	resizePoint.ZIndex = 99999991
	resizePoint.Text = ""
	resizePoint.Size = UDim2.new(0, 8, 0, 8)

	PointJanitor:Add(resizePoint)

	return resizePoint
end

local function addResizePoints(object)
	local topLeft = createResizePoint("TopLeft")
	topLeft.Position = UDim2.new(0, -resizePointSize.X / 2, 0, -resizePointSize.Y / 2)
	topLeft.AnchorPoint = Vector2.new(0, 0)
	topLeft.Parent = object

	local topRight = createResizePoint("TopRight")
	topRight.Position = UDim2.new(1, -resizePointSize.X / 2, 0, -resizePointSize.Y / 2)
	topRight.AnchorPoint = Vector2.new(0, 0)
	topRight.Parent = object

	local bottomLeft = createResizePoint("BottomLeft")
	bottomLeft.Position = UDim2.new(0, -resizePointSize.X / 2, 1, -resizePointSize.Y / 2)
	bottomLeft.AnchorPoint = Vector2.new(0, 0)
	bottomLeft.Parent = object

	local bottomRight = createResizePoint("BottomRight")
	bottomRight.Position = UDim2.new(1, -resizePointSize.X / 2, 1, -resizePointSize.Y / 2)
	bottomRight.AnchorPoint = Vector2.new(0, 0)
	bottomRight.Parent = object

	local top = createResizePoint("Top")
	top.Position = UDim2.new(0.5, -resizePointSize.X / 2, 0, -resizePointSize.Y / 2)
	top.AnchorPoint = Vector2.new(0, 0)
	top.Parent = object

	local left = createResizePoint("Left")
	left.Position = UDim2.new(0, -resizePointSize.X / 2, 0.5, -resizePointSize.Y / 2)
	left.AnchorPoint = Vector2.new(0, 0.5)
	left.Parent = object

	local bottom = createResizePoint("Bottom")
	bottom.Position = UDim2.new(0.5, -resizePointSize.X / 2, 1, -resizePointSize.Y / 2)
	bottom.AnchorPoint = Vector2.new(0.5, 0)
	bottom.Parent = object

	local right = createResizePoint("Right")
	right.Position = UDim2.new(1, -resizePointSize.X / 2, 0.5, -resizePointSize.Y / 2)
	right.AnchorPoint = Vector2.new(0, 0.5)
	right.Parent = object
end

local Manipulation = {}
Manipulation.Mode = 0

function Manipulation.Start()
	Cleanup:Add(SelectorSystem.Triggered:Connect(function(object)
		SelectedJanitor:Cleanup()
		PointJanitor:Cleanup()

		addResizePoints(object)

		-- Check mode, initialize correct UI
		SelectedJanitor:Add(object.Detector.MouseButton1Down:Connect(function() end))
		-- End mode
		SelectedJanitor:Add(object.Detector.MouseButton1Up:Connect(function() end))
	end))

	-- End mode
	Cleanup:Add(UserInterfaceSystem.UI.Detector.MouseButton1Up:Connect(function() end))

	-- Perform object manipulations
	-- 0: nothing
	-- 1: move
	-- 2: resize
	-- 3: rotate
	Cleanup:Add(MouseSystem.Moved:Connect(function()
		local object: Frame = SelectorSystem.Selected
	end))
end

function Manipulation.Destroy()
	Cleanup:Cleanup()
	SelectedJanitor:Cleanup()
end

return Manipulation
