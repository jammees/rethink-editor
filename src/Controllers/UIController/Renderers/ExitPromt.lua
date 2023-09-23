local PluginFramework = require(script.Parent.Parent.Parent.Parent.Library.PluginFramework)
local Utility = require(script.Parent.Parent.Utility)
local IrisTypes = require(script.Parent.Parent.Parent.Parent.Vendors["Iris-plugin"].Types)

---@module src.Controllers.ConfigController
local ConfigController = PluginFramework.GetController("ConfigController")
---@module src.Controllers.UIController
local UIController = PluginFramework.GetController("UIController")

return function(Iris: IrisTypes.Iris)
	local positionState = Iris.ComputedState(UIController.WidgetSize, function(firstState: Vector2)
		local size = ConfigController.Config.CreateNewObjectSize:get()

		return Vector2.new(firstState.X / 2 - size.X / 2, firstState.Y / 2 - size.Y / 2)
	end)

	Iris.Window({
		"Confirm exit",
		[Iris.Args.Window.NoCollapse] = true,
		[Iris.Args.Window.NoMove] = true,
		[Iris.Args.Window.NoScrollbar] = true,
		[Iris.Args.Window.NoResize] = true,
	}, {
		size = ConfigController.Config.CreateNewObjectSize,
		position = positionState,
		isOpened = Utility.ExitPromtActive,
	})

	Iris.Text({ "Are you sure you want to exit the application?", [Iris.Args.Text.Wrapped] = true })

	Iris.SameLine()
	if Iris.Button({ "Yes" }).clicked() then
		UIController.Widget.Enabled = false
	end
	if Iris.Button({ "No" }).clicked() then
		Utility.ExitPromtActive:set(false)
	end
	Iris.End()

	Iris.End()
end
