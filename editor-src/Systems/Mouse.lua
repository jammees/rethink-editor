local library = script.Parent.Parent.Library

local UserInterfaceSystem = require(script.Parent.UserInterface)
local LoggerSystem = require(script.Parent.Logger)

local Janitor = require(library.Janitor).new()
local Signal = require(library.Signal)

local oldMousePosition = Vector2.new()

local Mouse = {}
Mouse.X = 0
Mouse.Y = 0
Mouse.Moved = Signal.new()
Mouse.MouseButton1Down = Signal.new()
Mouse.MouseButton1Up = Signal.new()
Mouse.StateChanged = Signal.new()
Mouse.State = ""

function Mouse.Start()
	Janitor:Add(UserInterfaceSystem.UI.Detector.MouseMoved:Connect(function(x: number, y: number)
		oldMousePosition = Vector2.new(Mouse.X, Mouse.Y)

		Mouse.X = x
		Mouse.Y = y

		Mouse.Moved:Fire()
	end))

	Janitor:Add(UserInterfaceSystem.UI.Detector.InputBegan:Connect(function(inputObject: InputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			Mouse.State = "MOUSEBUTTONDOWN"
			Mouse.StateChanged:Fire()
			Mouse.MouseButton1Down:Fire()

			return
		end
	end))

	Janitor:Add(UserInterfaceSystem.UI.Detector.InputEnded:Connect(function(inputObject: InputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			Mouse.State = "MOUSEBUTTONUP"
			Mouse.StateChanged:Fire()
			Mouse.MouseButton1Up:Fire()

			Mouse.State = ""
			Mouse.StateChanged:Fire()

			return
		end
	end))
end

function Mouse.GetDelta(): Vector2
	return Vector2.new(Mouse.X - oldMousePosition.X, Mouse.Y - oldMousePosition.Y)
end

function Mouse.Destroy()
	Janitor:Cleanup()
end

return Mouse
