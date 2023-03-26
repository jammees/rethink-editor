local library = script.Parent.Parent.Library

local ObjectSystem = require(script.Parent.Object)

local Janitor = require(library.Janitor).new()
local Signal = require(library.Signal)

local previousSelected = nil

local Selector = {}
Selector.Selected = nil
Selector.SelectionChanged = Signal.new()
Selector.Triggered = Signal.new()

function Selector.Start()
	Janitor:Add(ObjectSystem.Added:Connect(function(object)
		Janitor:Add(object.Detector.MouseButton1Click:Connect(function()
			previousSelected = Selector.Selected

			if Selector.Selected then
				Selector.Selected.ZIndex = 1
			end

			Selector.Selected = object
			--object.ZIndex = 9999999

			Selector.Triggered:Fire(object)

			if previousSelected ~= Selector.Selected then
				Selector.SelectionChanged:Fire(object)
			end
		end))
	end))
end

function Selector.Destroy()
	Janitor:Cleanup()
end

return Selector
