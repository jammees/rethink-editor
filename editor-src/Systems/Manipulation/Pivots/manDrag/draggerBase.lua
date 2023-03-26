local POS_DATA = {
	[1] = function(obj)
		return Vector2.new(
			obj.AbsoluteSize.X / 2 + obj.AbsolutePosition.X,
			obj.AbsoluteSize.Y / 2 + obj.AbsolutePosition.X
		)
	end,
}

local TYPE_DATA = {
	[1] = function(obj)
		local pos = POS_DATA[1](obj)

		local inst = Instance.new("ImageButton")
		inst.Position = UDim2.fromOffset(pos.X, pos.Y)
		inst.Size = UDim2.fromOffset(10, 10)
		inst.BackgroundColor3 = Color3.fromRGB(228, 248, 75)
		inst.ZIndex = 9999991

		return obj
	end,
}

local DRAG_DIR = {
	[1] = { 1, 1 },
	[2] = { 1, 0 },
	[3] = { 0, 1 },
}

local library = script.Parent.Parent.Parent.Parent.Parent.Library

local UserInterfaceSystem = require(script.Parent.Parent.Parent.Parent.UserInterface)
local MouseSystem = require(script.Parent.Parent.Parent.Parent.Mouse)

local Signal = require(library.Signal)
local Janitor = require(library.Janitor)

local function createDraggerPoint(object, type)
	local obj = TYPE_DATA[type](object)

	obj.Parent = UserInterfaceSystem.Ui

	return obj
end

local DraggerBase = {}

function DraggerBase.new(object: any, type: number)
	local self = setmetatable({}, DraggerBase)

	self.Janitor = Janitor.new()
	self.DragStart = Signal.new()
	self.DragEnd = Signal.new()

	self.Point = createDraggerPoint(object, type)
	self.Type = type
	self.DragDir = DRAG_DIR[type]

	return self
end

return DraggerBase
