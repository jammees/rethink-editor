local PluginFramework = require(script.Parent.Parent.Parent.Parent.Library.PluginFramework)
local Iris = require(script.Parent.Parent.Parent.Parent.Vendors["Iris-plugin"])
local Utility = require(script.Parent.Parent.Utility)

---@module src.Controllers.ConfigController
local ConfigController = PluginFramework.GetController("ConfigController")

return function()
	local sizeState = Iris.ComputedState(Utility.WidgetSize, function(firstState: Vector2)
		return Vector2.new(firstState.X, ConfigController.Config.MenuBarSizeY.value)
	end)

	Iris.Window({
		"Toolbar",
		[Iris.Args.Window.NoCollapse] = true,
		[Iris.Args.Window.NoClose] = true,
		[Iris.Args.Window.NoMove] = true,
		[Iris.Args.Window.NoScrollbar] = true,
		[Iris.Args.Window.NoResize] = true,
		[Iris.Args.Window.NoTitleBar] = true,
	}, { size = sizeState, position = Vector2.new() })

	Iris.SameLine()
	Iris.Button({ "Test" })
	Iris.End()
	Iris.Separator()

	Iris.End()
end