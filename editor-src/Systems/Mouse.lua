local library = script.Parent.Parent.Library

local Janitor = require(library.Janitor).new()
local Signal = require(library.Signal)
local UserInterfaceSystem = require(script.Parent.UserInterface)

local Mouse = {}
Mouse.X = 0
Mouse.Y = 0
Mouse.Moved = Signal.new()

function Mouse.Start()
	Janitor:Add(UserInterfaceSystem.UI.Detector.MouseMoved:Connect(function(x: number, y: number)
		Mouse.X = x
		Mouse.Y = y
		Mouse.Moved:Fire()
	end))
end

function Mouse.Destroy()
	Janitor:Cleanup()
end

return Mouse
