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

local function man_Resize(reference: any, pointData: { any }, isDefaultAnchorPoint: boolean)
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

	if pointData[1] == -1 then
		object.man_fPosition = Vector2.new(Snap(object.man_OGPosition.X + mouseDelta.X), object.man_fPosition.Y)
		object.man_fSize = Vector2.new(Snap(object.man_OGSize.X - mouseDelta.X), object.man_fSize.Y)
	elseif pointData[1] == 1 then
		object.man_fSize = Vector2.new(Snap(object.man_OGSize.X + mouseDelta.X), object.man_fSize.Y)
	end

	if pointData[2] == -1 then
		object.man_fPosition = Vector2.new(object.man_fPosition.X, Snap(object.man_fPosition.Y + mouseDelta.Y))
		object.man_fSize = Vector2.new(object.man_fSize.X, Snap(object.man_OGSize.Y - mouseDelta.Y))
	elseif pointData[2] == 1 then
		object.man_fSize = Vector2.new(object.man_fSize.X, Snap(object.man_OGSize.Y + mouseDelta.Y))
	end
end

local Handler = {}

function Handler.Mount(object: any)
	if not object then
		return
	end

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
			local savedAP = reference.Object.AnchorPoint
			local anchorOffset = AnchorPointOffset(reference.Object.anchorPoint, reference.Object.AbsoluteSize)
			local objectSize: UDim2 = reference.Object.Size
			local objectPosition: UDim2 = reference.Object.Position
			local scaleDirection = pivotClass.ActivePoint:GetRelativePosition()

			man_Resize(reference, scaleDirection, reference.Object.AnchorPoint == Vector2.new(0, 0))

			reference.Object.AnchorPoint = Vector2.new(0, 0)

			object.Size = UDim2.new(
				objectSize.X.Scale,
				reference.EditorData.man_fSize.X,
				objectSize.Y.Scale,
				reference.EditorData.man_fSize.Y
			)

			-- If anyone has any idea how to fix the bug where if the anchor point is not 0, 0 and
			-- we are trying to scale the object from the left the object starts to move the
			-- same amount as the mouse.
			-- I tried couple of things to fix this, but with no luck so far. If you have
			-- any idea how to fix this, please: Create an issue.

			object.Position = UDim2.new(
				objectPosition.X.Scale,
				reference.EditorData.man_fPosition.X - anchorOffset.X,
				objectPosition.Y.Scale,
				reference.EditorData.man_fPosition.Y - ConfigSystem.ui_TopbarOffset:get() - anchorOffset.Y
			) -- The reason why I remove 130 is because of the topbar
			-- for some reason if this wouldn't exist the object would jump down exactly 130 pixels.

			reference.Object.AnchorPoint = savedAP

			reference.EditorData.man_OGSize = object.AbsoluteSize
			reference.EditorData.man_OGPosition = object.AbsolutePosition

			-- Save changes
			reference.ExportData.Properties["Position"] = object.Position
			reference.ExportData.Properties["Size"] = object.Size

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
