local library = script.Parent.Parent.Library

local UserInterfaceSystem = require(script.Parent.UserInterface)
local MouseSystem = require(script.Parent.Mouse)
local LoggerSystem = require(script.Parent.Logger)

local Signal = require(library.Signal)
local Janitor = require(library.Janitor).new()
local DefaultProperties = require(script["DefaultProperties-v2"])

local entries = {}
local entriesHash = {}

local Object = {}
Object.Added = Signal.new()
Object.MB2Clicked = Signal.new()

function Object.New(kind: string, class: string)
	local object = Instance.new(class)

	local objectReference = {
		Type = kind,
		ExportData = {
			Properties = {},
			Symbols = {},
		},
		EditorData = {},
		Object = object,
		Cleanup = Janitor.new(),
	}

	for i, v in pairs(DefaultProperties[object.ClassName]) do
		object[i] = v
	end

	object.AnchorPoint = Vector2.new(0, 0)
	object.Position = UDim2.fromOffset(MouseSystem.X, MouseSystem.Y - 130)
	object.Parent = UserInterfaceSystem.UI.Workspace

	-- Save position
	objectReference.ExportData.Properties["Position"] = object.Position

	local mouseDetector = Instance.new("TextButton")
	mouseDetector.BackgroundTransparency = 1
	mouseDetector.TextTransparency = 1
	mouseDetector.Name = "Detector"
	mouseDetector.Size = UDim2.fromScale(1, 1)
	mouseDetector.Parent = object

	objectReference.EditorData.man_MousePressedDown = false
	objectReference.EditorData.man_dragging = { false }
	objectReference.EditorData.man_first = true
	objectReference.EditorData.man_OGSize = object.AbsoluteSize
	objectReference.EditorData.man_OGPosition = object.AbsolutePosition
	objectReference.EditorData.man_fSize = object.AbsoluteSize
	objectReference.EditorData.man_fPosition = object.AbsolutePosition

	Object.Added:Fire(object)

	local reservedPosition = #entries + 1
	entries[reservedPosition] = objectReference
	entriesHash[object] = reservedPosition

	-- Cleanup
	Janitor:Add(objectReference.Cleanup)
	objectReference.Cleanup:Add(object)
	objectReference.Cleanup:Add(function()
		entries[reservedPosition] = nil
		entriesHash[object] = nil
	end)
	objectReference.Cleanup:Add(mouseDetector.MouseButton2Click:Connect(function()
		Object.MB2Clicked:Fire(objectReference)
	end))

	LoggerSystem.Log(`[Object] Created new {kind} at entry: {reservedPosition}`)
end

function Object.GetFromObject(object: any)
	return entries[entriesHash[object]]
end

function Object.GetAll() end

function Object.ClearAll()
	Janitor:Cleanup()
	table.clear(entries)
end

return Object
