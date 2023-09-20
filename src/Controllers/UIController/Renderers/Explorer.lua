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

return function(Iris: IrisTypes.Iris)
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

	Iris.Window({
		"Explorer",
		[Iris.Args.Window.NoCollapse] = true,
		[Iris.Args.Window.NoClose] = true,
		[Iris.Args.Window.NoMove] = true,
		[Iris.Args.Window.NoScrollbar] = true,
		[Iris.Args.Window.NoResize] = true,
	}, { size = sizeState, position = positionState })

	Iris.SameLine()
	if Iris.Button({ "Create Object" }).clicked() then
		Utility.CreateNewObjectActive:set(true)
	end
	Iris.End()
	Iris.Separator()

	for index, data in ObjectController.Objects do
		local objectSelecable = Iris.Selectable({ data.Object.Name, index }, { index = selectedState })

		if objectSelecable.selected() then
			SelectionController.SelectedObject = data
			SelectionController.NewSelection:Fire()
			SelectionController.Triggered:Fire()
		end
	end

	Iris.End()
end
