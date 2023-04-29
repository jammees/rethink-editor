local ICON_SET_ID = "rbxassetid://12905796010"
local ICON_SET_MAP = {
	[1] = Vector2.new(0, 0),
	[2] = Vector2.new(256, 0),
	[3] = Vector2.new(512, 0),
	[4] = Vector2.new(0, 256),
	[5] = Vector2.new(256, 256),
	[6] = Vector2.new(512, 256),
	[8] = Vector2.new(256, 512),
}

-- First two are used for drag directions and the last one is for image id, the last two are anchor points
local POINT_DATA = {
	{ 0, -1, 2, 0.5, 0.3 }, -- TOP
	{ 1, -1, 5, 1, 0 }, -- TOPRIGHT
	{ 1, 0, 3, 0.7, 0.5 }, -- RIGHT
	{ 1, 1, 1, 1, 1 }, -- BOTTOMRIGHT
	{ 0, 1, 2, 0.5, 0.7 }, -- BOTTOM
	{ -1, 1, 4, 0, 1 }, -- BOTTOMLEFT
	{ -1, 0, 3, 0.3, 0.5 }, -- LEFT
	{ -1, -1, 6, 0, 0 }, -- TOPLEFT
}

-- 1: top
-- 2: topright
-- 3: right
-- 4: bottomright
-- 5: bottom
-- 6: bottomleft
-- 7: left
-- 8: topleft
local POINT_POSITION_HANDLE = {
	[1] = function(object: GuiBase2d)
		return Vector2.new(object.AbsoluteSize.X / 2 + object.AbsolutePosition.X, object.AbsolutePosition.Y),
			Vector2.new(30, 30)
	end,
	[2] = function(object: GuiBase2d)
		return Vector2.new(object.AbsoluteSize.X + object.AbsolutePosition.X, object.AbsolutePosition.Y),
			Vector2.new(30, 30)
	end,
	[3] = function(object: GuiBase2d)
		return Vector2.new(
			object.AbsoluteSize.X + object.AbsolutePosition.X,
			object.AbsoluteSize.Y / 2 + object.AbsolutePosition.Y
		),
			Vector2.new(30, 30)
	end,
	[4] = function(object: GuiBase2d)
		return Vector2.new(
			object.AbsoluteSize.X + object.AbsolutePosition.X,
			object.AbsoluteSize.Y + object.AbsolutePosition.Y
		),
			Vector2.new(30, 30)
	end,
	[5] = function(object: GuiBase2d)
		return Vector2.new(
			object.AbsoluteSize.X / 2 + object.AbsolutePosition.X,
			object.AbsoluteSize.Y + object.AbsolutePosition.Y
		),
			Vector2.new(30, 30)
	end,
	[6] = function(object: GuiBase2d)
		return Vector2.new(object.AbsolutePosition.X, object.AbsoluteSize.Y + object.AbsolutePosition.Y),
			Vector2.new(30, 30)
	end,
	[7] = function(object: GuiBase2d)
		return Vector2.new(object.AbsolutePosition.X, object.AbsoluteSize.Y / 2 + object.AbsolutePosition.Y),
			Vector2.new(30, 30)
	end,
	[8] = function(object: GuiBase2d)
		return Vector2.new(object.AbsolutePosition.X, object.AbsolutePosition.Y), Vector2.new(30, 30)
	end,
}

local library = script.Parent.Parent.Parent.Parent.Parent.Library

local UserInterfaceSystem = require(script.Parent.Parent.Parent.Parent.UserInterface)
local MouseSystem = require(script.Parent.Parent.Parent.Parent.Mouse)

local Signal = require(library.Signal)
local Janitor = require(library.Janitor)

local function createResizePoint(object: GuiBase2d, position: number, size: number)
	local point = Instance.new("ImageButton")
	point.Name = position
	point.BackgroundTransparency = 1
	point.Image = ICON_SET_ID
	point.ImageRectSize = Vector2.new(256, 256)
	point.ImageRectOffset = ICON_SET_MAP[POINT_DATA[position][3]]
	point.BackgroundColor3 = Color3.new(0.941176, 0.078431, 0.078431)
	point.BorderSizePixel = 0
	point.ImageTransparency = 0.5
	point.ZIndex = 99999991

	local pointPosition, bSize = POINT_POSITION_HANDLE[position](object)
	point.AnchorPoint = Vector2.new(POINT_DATA[position][4], POINT_DATA[position][5])

	point.Size = UDim2.fromOffset(bSize.X, bSize.Y)

	point.Position = UDim2.fromOffset(pointPosition.X, pointPosition.Y)

	point.Parent = UserInterfaceSystem.UI

	return point
end

local Point = {}
Point.__index = Point

function Point.new(object: GuiBase2d, position: number, size: number)
	local self = setmetatable({}, Point)

	self.Janitor = Janitor.new()
	self.DragStart = Signal.new()
	self.DragEnd = Signal.new()

	self.Active = false
	self.Position = position
	self.Data = POINT_DATA[position]

	-- create the point object
	self.Object = object
	self.Point = createResizePoint(object, position, size)

	self.Janitor:Add(self.Point)

	-- Handle events
	self.Janitor:Add(self.Point.MouseButton1Down:Connect(function()
		self.Active = true

		self.DragStart:Fire(self)
	end))

	self.Janitor:Add(self.Point.MouseButton1Up:Connect(function()
		if not self.Active then
			return
		end

		self.Active = false

		self.DragEnd:Fire(self)
	end))

	self.Janitor:Add(self.Point.MouseEnter:Connect(function()
		self.Point.ImageTransparency = 0
	end))

	self.Janitor:Add(self.Point.MouseLeave:Connect(function()
		self.Point.ImageTransparency = 0.5
	end))

	self.Janitor:Add(MouseSystem.MouseButton1Up:Connect(function()
		if not self.Active then
			return
		end

		self.Active = false

		self.DragEnd:Fire(self)
	end))

	return self
end

function Point:GetRelativePosition()
	return POINT_DATA[self.Position]
end

function Point:UpdatePosition()
	local pointPosition = POINT_POSITION_HANDLE[self.Position](self.Object)
	self.Point.Position = UDim2.fromOffset(pointPosition.X, pointPosition.Y)
end

function Point:Destroy()
	self.Janitor:Cleanup()

	table.clear(self)
end

return Point
