local library = script.Parent.Parent.Parent.Parent.Parent.Library

local Janitor = require(library.Janitor).new()
local PointClass = require(script.Parent["Point.class"])
local Signal = require(library.Signal)

local PointManager = {}
PointManager.ActivePoint = nil
PointManager.Points = {}
PointManager.PointSize = 8
PointManager.DragStarted = Signal.new()
PointManager.DragEnded = Signal.new()

function PointManager.AttachTo(object: any)
	Janitor:Cleanup()
	table.clear(PointManager.Points)

	for i = 1, 8, 1 do
		local point = PointClass.new(object, i, PointManager.PointSize)

		Janitor:Add(point)
		table.insert(PointManager.Points, point)

		Janitor:Add(point.DragStart:Connect(function(pointClass)
			PointManager.ActivePoint = pointClass
			PointManager.DragStarted:Fire(pointClass)
		end))

		Janitor:Add(point.DragEnd:Connect(function(pointClass)
			if PointManager.ActivePoint == pointClass then
				PointManager.ActivePoint = nil
				PointManager.DragEnded:Fire(pointClass)
			end
		end))
	end
end

function PointManager.RedrawPoints()
	for _, point in ipairs(PointManager.Points) do
		point:UpdatePosition()
	end
end

function PointManager.IsActive()
	return PointManager.ActivePoint ~= nil
end

function PointManager.DestroyPoints()
	Janitor:Cleanup()
end

return PointManager
