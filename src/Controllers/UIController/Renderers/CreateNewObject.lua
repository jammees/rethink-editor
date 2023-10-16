local PluginFramework = require(script.Parent.Parent.Parent.Parent.Library.PluginFramework)
local Utility = require(script.Parent.Parent.Utility)
local IrisTypes = require(script.Parent.Parent.Parent.Parent.Vendors["Iris-plugin"].Types)

---@module src.Controllers.ConfigController
local ConfigController = PluginFramework.GetController("ConfigController")
---@module src.Controllers.ObjectController
local ObjectController = PluginFramework.GetController("ObjectController")
---@module src.Controllers.UIController
local UIController = PluginFramework.GetController("UIController")
---@module src.Controllers.SelectionController
local SelectionController = PluginFramework.GetController("SelectionController")

local CreateNewObject = {}

CreateNewObject.Priority = 10000

function CreateNewObject.Render(Iris: IrisTypes.Iris)
	local nameState = Iris.State("")
	local kindState = Iris.State("UIbase")
	local classState = Iris.State("Frame")

	local positionState = Iris.ComputedState(UIController.WidgetSize, function(firstState: Vector2)
		local size = ConfigController.Config.CreateNewObjectSize:get()

		return Vector2.new(firstState.X / 2 - size.X / 2, firstState.Y / 2 - size.Y / 2)
	end)

	Iris.Window({
		"Create new object",
		[Iris.Args.Window.NoCollapse] = true,
		[Iris.Args.Window.NoMove] = true,
		[Iris.Args.Window.NoScrollbar] = true,
		[Iris.Args.Window.NoResize] = true,
	}, {
		size = ConfigController.Config.CreateNewObjectSize,
		position = positionState,
		isOpened = Utility.CreateNewObjectActive,
	})

	Iris.InputText({ "Name" }, { text = nameState })
	Iris.ComboArray({ "Class" }, { index = classState }, { "Frame", "TextLabel", "ImageLabel" })
	Iris.ComboArray({ "Kind" }, { index = kindState }, { "UIbase", "Rigidbody" })

	Iris.PushConfig({ TextColor = Color3.fromRGB(117, 117, 117) })
	Iris.Text({ "This can be later configured!" })
	Iris.PopConfig()

	Iris.SameLine()
	if Iris.Button({ "Cancel" }).clicked() then
		Utility.CreateNewObjectActive:set(false)

		nameState:set("")
		kindState:set("UIbase")
		classState:set("Frame")
	end
	if Iris.Button({ "Done" }).clicked() then
		Utility.CreateNewObjectActive:set(false)

		task.spawn(function()
			SelectionController:ChangeTo(
				ObjectController:CreateObject(classState.value, kindState.value, { Name = nameState.value })
			)
		end)

		nameState:set("")
		kindState:set("UIbase")
		classState:set("Frame")
	end
	Iris.End()

	Iris.End()
end

return CreateNewObject
