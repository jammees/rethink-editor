local library = script.Parent.Parent.Library

local UserInterfaceSystem = require(script.Parent.UserInterface)
local MouseSystem = require(script.Parent.Mouse)

local Signal = require(library.Signal)
local Janitor = require(library.Janitor).new()
local DefaultProperties = require(script.DefaultProperties)

local entries = {}

local Object = {}
Object.Added = Signal.new()

function Object.New(type: string)
	local object = Instance.new("Frame")

	local objectReference = {
		Type = type,
		Properties = {},
		Object = object,
	}

	for i, v in pairs(DefaultProperties[object.ClassName]) do
		object[i] = v
	end

	object.AnchorPoint = Vector2.new(0, 0)
	object.Position = UDim2.fromOffset(MouseSystem.X, MouseSystem.Y)
	object.Parent = UserInterfaceSystem.UI

	local mouseDetector = Instance.new("TextButton")
	mouseDetector.BackgroundTransparency = 1
	mouseDetector.TextTransparency = 1
	mouseDetector.Name = "Detector"
	mouseDetector.Size = UDim2.fromScale(1, 1)
	mouseDetector.Parent = object

	Object.Added:Fire(object)

	Janitor:Add(object)

	table.insert(entries, objectReference)
end

function Object.GetAll() end

function Object.ClearAll()
	Janitor:Cleanup()
	table.clear(entries)
end

return Object
