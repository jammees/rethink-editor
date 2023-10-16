local PluginFramework = require(script.Parent.Parent.Parent.Parent.Library.PluginFramework)
local Utility = require(script.Parent.Parent.Utility)
local IrisTypes = require(script.Parent.Parent.Parent.Parent.Vendors["Iris-plugin"].Types)

---@module src.Controllers.ConfigController
local ConfigController = PluginFramework.GetController("ConfigController")
---@module src.Controllers.ObjectController
local ObjectController = PluginFramework.GetController("ObjectController")
---@module src.Controllers.SelectionController
local SelectionController = PluginFramework.GetController("SelectionController")
---@module src.Controllers.UIController
local UIController = PluginFramework.GetController("UIController")

--FIXME: objectSelectable does not render correctly in some scenarious
-- such as parenting an object which has a children already to a
-- different object.
--NOTE: This could maybe be fixed by re-rendering everything in the explorer when the hierarchy
-- changes
-- more experimentation is required :)
--NOTE 2: Should clean up all of the rendering code
--NOTE 3: Add an abstract class for rendering promts

local Explorer = {}

Explorer.Priority = 00001

function Explorer.Render(Iris: IrisTypes.Iris)
	local selectedState = Iris.State(1)

	local sizeState = Iris.ComputedState(UIController.WidgetSize, function(firstState: Vector2)
		return Vector2.new(
			ConfigController.Config.ExplorerSizeX.value,
			firstState.Y - ConfigController.Config.MenuBarSizeY.value
		)
	end)

	local positionState = Iris.ComputedState(ConfigController.Config.MenuBarSizeY, function(firstState: number)
		return Vector2.new(0, firstState)
	end)

	local window = Iris.Window({
		"Explorer",
		[Iris.Args.Window.NoCollapse] = true,
		[Iris.Args.Window.NoClose] = true,
		[Iris.Args.Window.NoMove] = true,
		[Iris.Args.Window.NoScrollbar] = true,
		[Iris.Args.Window.NoResize] = true,
	}, { size = sizeState, position = positionState })
	local childContainer: ScrollingFrame = window.Instance.WindowButton.ChildContainer
	childContainer.AutomaticCanvasSize = Enum.AutomaticSize.XY
	childContainer.ScrollBarThickness = 5
	childContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	childContainer.TopImage = childContainer.MidImage
	childContainer.BottomImage = childContainer.MidImage
	childContainer.ScrollBarImageColor3 = Iris._config.TitleBgActiveColor

	Iris.SameLine()
	if Iris.Button({ "Create Object" }).clicked() then
		Utility.CreateNewObjectActive:set(true)
	end
	Iris.End()
	Iris.Separator()

	local function GenerateButton(index, data)
		local objectSelectable = Iris.Selectable(
			{ data.Object.Name, index },
			{ index = ConfigController.Config.Explorer_Selected_ID }
		)
		objectSelectable.Instance.Size = UDim2.fromOffset(
			ConfigController.Config.ExplorerSizeX.value - Iris._config.WindowPadding.X * 2,
			objectSelectable.Instance.AbsoluteSize.Y
		)

		if objectSelectable.selected() then
			SelectionController.SelectedObject = data
			SelectionController.NewSelection:Fire()
			SelectionController.Triggered:Fire()
		end

		return objectSelectable
	end

	local function GetDeepness(object: GuiBase2d, carrier: number?)
		if object.Parent == UIController.Widget.Workspace then
			return carrier
		end

		GetDeepness(object.Parent, carrier + 5)
	end

	local function GetChildrenOf(searchedObject: GuiBase2d)
		local children = {}

		for _, child in searchedObject:GetChildren() do
			for _, object in ObjectController.Objects do
				if not (child == object.Object) then
					continue
				end

				table.insert(children, object)
			end
		end

		return children
	end

	local function ParseChildren(childrenData)
		for _, data in childrenData do
			Iris.Indent(GetDeepness(data.Object, 0))
			GenerateButton(ObjectController:GetIndexFromObject(data.Object), data)

			local children = GetChildrenOf(data.Object)

			if #children > 0 then
				ParseChildren(children)
			end
			Iris.End()
		end
	end

	for _, data in ObjectController.Objects do
		if data.Object.Parent ~= UIController.Widget.Workspace then
			continue
		end

		ParseChildren({ data })
	end

	Iris.End()
end

return Explorer
