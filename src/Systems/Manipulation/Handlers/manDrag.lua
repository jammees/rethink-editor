local library = script.Parent.Parent.Parent.Parent.Library
local systems = script.Parent.Parent.Parent
local pivots = script.Parent.Parent.Pivots

local MouseSystem = require(systems.Mouse)
local ObjectSystem = require(systems.Object)
local UserInterfaceSystem = require(systems.UserInterface)
local ConfigSystem = require(systems.Config).Get()

local Janitor = require(library.Janitor).new()

local mouseDeltaCounter = Vector2.new()

-- Slightly edited version of the function found in Nature2D
local function AnchorPointOffset(anchorPoint: Vector2, size: Vector2)
	return (Vector2.new(0, 0) - anchorPoint) * size
end

local function Snap(Input)
	return ConfigSystem.man_SnapToGrid:get()
			and math.floor(Input / ConfigSystem.man_GridSize:get() + 0.5) * ConfigSystem.man_GridSize:get()
		or Input
end

local function man_DragXY(reference: any, dragX: boolean, dragY: boolean)
	local object = reference.EditorData
	local mouseDelta = MouseSystem.GetDelta()

	if ConfigSystem.man_SnapToGrid:get() then
		local gridSize = ConfigSystem.man_GridSize:get()

		if math.abs(mouseDeltaCounter.X) >= gridSize or math.abs(mouseDeltaCounter.Y) >= gridSize then
			mouseDelta = mouseDeltaCounter
			mouseDeltaCounter = Vector2.new()
		else
			mouseDeltaCounter += mouseDelta
		end
	end

	if dragX == 1 then
		object.man_fPosition = Vector2.new(Snap(object.man_OGPosition.X + mouseDelta.X), object.man_fPosition.Y)
	end

	if dragY == 1 then
		object.man_fPosition = Vector2.new(object.man_fPosition.X, Snap(object.man_OGPosition.Y + mouseDelta.Y))
	end
end

local Handler = {}

function Handler.Mount(object: any)
	if not object then
		return
	end

	local reference = ObjectSystem.GetFromObject(object)
	local pivotClass = require(pivots.manDrag.draggerBase).new(object)

	Janitor:Add(pivotClass)

	local isDragging = false
	local dragDirection = { 0, 0 }

	Janitor:Add(pivotClass.DragStart:Connect(function(dragDir)
		dragDirection = dragDir
		isDragging = true

		UserInterfaceSystem.UI.Detector.ZIndex = 25
	end))

	Janitor:Add(pivotClass.DragEnd:Connect(function()
		isDragging = false
		dragDirection = nil

		UserInterfaceSystem.UI.Detector.ZIndex = 1
	end))

	Janitor:Add(UserInterfaceSystem.UI.Detector.MouseButton1Up:Connect(function()
		isDragging = false
		dragDirection = nil

		UserInterfaceSystem.UI.Detector.ZIndex = 1
	end))

	Janitor:Add(MouseSystem.Moved:Connect(function()
		if isDragging == true then
			man_DragXY(reference, table.unpack(dragDirection))

			local anchorOffset = AnchorPointOffset(reference.Object.anchorPoint, reference.Object.AbsoluteSize)

			object.Position = UDim2.fromOffset(
				reference.EditorData.man_fPosition.X - anchorOffset.X,
				reference.EditorData.man_fPosition.Y - ConfigSystem.ui_TopbarOffset:get() - anchorOffset.Y
			)

			reference.EditorData.man_OGPosition = object.AbsolutePosition

			-- Save changes
			reference.ExportData.Properties["Position"] = object.Position

			pivotClass:UpdatePos()
		end
	end))
end

function Handler.Dismount()
	Janitor:Cleanup()
end

return Handler
