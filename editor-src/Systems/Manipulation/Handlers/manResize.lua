local library = script.Parent.Parent.Parent.Parent.Library
local systems = script.Parent.Parent.Parent
local pivots = script.Parent.Parent.Pivots

local MouseSystem = require(systems.Mouse)
local ObjectSystem = require(systems.Object)
local UserInterfaceSystem = require(systems.UserInterface)

local Janitor = require(library.Janitor).new()

local function man_Resize(reference: any, pointData: { any })
	local object = reference.EditorData
	local mouseDelta = MouseSystem.GetDelta()

	if pointData[1] == -1 then
		object.man_fSize = Vector2.new(object.man_OGSize.X - mouseDelta.X, object.man_fSize.Y)
		object.man_fPosition = Vector2.new(object.man_OGPosition.X + mouseDelta.X, object.man_fPosition.Y)
	elseif pointData[1] == 1 then
		object.man_fSize = Vector2.new(object.man_OGSize.X + mouseDelta.X, object.man_fSize.Y)
	end

	if pointData[2] == -1 then
		object.man_fSize = Vector2.new(object.man_fSize.X, object.man_OGSize.Y - mouseDelta.Y)
		object.man_fPosition = Vector2.new(object.man_fPosition.X, object.man_fPosition.Y + mouseDelta.Y)
	elseif pointData[2] == 1 then
		object.man_fSize = Vector2.new(object.man_fSize.X, object.man_OGSize.Y + mouseDelta.Y)
	end
end

local Handler = {}

function Handler.Mount(object: any)
	local reference = ObjectSystem.GetFromObject(object)
	local pivotClass = require(pivots.manResize["Point.man"])

	local isResizing = false

	pivotClass.AttachTo(object)

	Janitor:Add(pivotClass.DragStarted:Connect(function()
		isResizing = true

		-- Make the detector have a higher ZIndex, so we can detect
		-- if the MB1 has been lifted up more accurately.
		-- If this didn't happen other object's detectors would interfere
		-- and won't detect it if the mouse has stopped holding MB1
		UserInterfaceSystem.UI.Detector.ZIndex = 25
	end))

	Janitor:Add(pivotClass.DragEnded:Connect(function()
		isResizing = false

		UserInterfaceSystem.UI.Detector.ZIndex = 1
	end))

	Janitor:Add(UserInterfaceSystem.UI.Detector.MouseButton1Up:Connect(function()
		isResizing = false

		UserInterfaceSystem.UI.Detector.ZIndex = 1
	end))

	Janitor:Add(MouseSystem.Moved:Connect(function()
		if isResizing and pivotClass.ActivePoint then
			man_Resize(reference, pivotClass.ActivePoint:GetRelativePosition())

			object.Size = UDim2.fromOffset(reference.EditorData.man_fSize.X, reference.EditorData.man_fSize.Y)
			object.Position =
				UDim2.fromOffset(reference.EditorData.man_fPosition.X, reference.EditorData.man_fPosition.Y - 130) -- The reason why I remove 130 is because of the topbar
			-- for some reason if this wouldn't exist the object would jump down exactly 130 pixels.

			reference.EditorData.man_OGSize = object.AbsoluteSize
			reference.EditorData.man_OGPosition = object.AbsolutePosition

			pivotClass.RedrawPoints()
		end
	end))

	-- Destroy points if cleaned up
	Janitor:Add(pivotClass, "DestroyPoints")
end

function Handler.Dismount()
	Janitor:Cleanup()
end

return Handler
