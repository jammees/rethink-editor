local library = script.Parent.Parent.Parent.Parent.Library
local systems = script.Parent.Parent.Parent
local pivots = script.Parent.Parent.Pivots

local MouseSystem = require(systems.Mouse)
local ObjectSystem = require(systems.Object)
local UserInterfaceSystem = require(systems.UserInterface)

local Janitor = require(library.Janitor).new()

local function man_DragXY(reference: any, dragX: boolean, dragY: boolean)
	local object = reference.EditorData
	local mouseDelta = MouseSystem.GetDelta()

	if dragX then
		object.man_fPosition = Vector2.new(object.man_OGPosition.X + mouseDelta.X, object.man_fPosition.Y)
	end

	if dragY then
		object.man_fPosition = Vector2.new(object.man_fPosition.X, object.man_OGPosition.Y + mouseDelta.Y)
	end
end

local Handler = {}

function Handler.Mount(object: any)
	local reference = ObjectSystem.GetFromObject(object)
	local pivotClass = require(pivots.manDrag.draggerBase).new(object, 1)

	local isDragging = false
	local resizeDir = { 0, 0 }

	Janitor:Add(UserInterfaceSystem.UI.Detector.MouseButton1Up:Connect(function()
		isDragging = false

		UserInterfaceSystem.UI.Detector.ZIndex = 1
	end))

	Janitor:Add(MouseSystem.Moved:Connect(function()
		if isDragging == true then
			--man_DragXY(reference, table.unpack(resizeDir))

			object.Position =
				UDim2.fromOffset(reference.EditorData.man_fPosition.X, reference.EditorData.man_fPosition.Y - 130)

			reference.EditorData.man_OGPosition = object.AbsolutePosition
		end
	end))
end

function Handler.Dismount()
	Janitor:Cleanup()
end

return Handler
