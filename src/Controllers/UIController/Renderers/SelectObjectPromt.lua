local PluginFramework = require(script.Parent.Parent.Parent.Parent.Library.PluginFramework)
local Utility = require(script.Parent.Parent.Utility)
local IrisTypes = require(script.Parent.Parent.Parent.Parent.Vendors["Iris-plugin"].Types)

---@module src.Controllers.ConfigController
local ConfigController = PluginFramework.GetController("ConfigController")
---@module src.Controllers.UIController
local UIController = PluginFramework.GetController("UIController")
---@module src.Controllers.ObjectController
local ObjectController = PluginFramework.GetController("ObjectController")

return function(Iris: IrisTypes.Iris)
	local positionState = Iris.ComputedState(UIController.WidgetSize, function(firstState: Vector2)
		local size = ConfigController.Config.SelectObjectSize:get()

		return Vector2.new(firstState.X / 2 - size.X / 2, firstState.Y / 2 - size.Y / 2)
	end)

	Iris.Window({
		"Select object",
		[Iris.Args.Window.NoCollapse] = true,
		[Iris.Args.Window.NoMove] = true,
		[Iris.Args.Window.NoScrollbar] = true,
		[Iris.Args.Window.NoResize] = true,
	}, {
		size = ConfigController.Config.SelectObjectSize,
		position = positionState,
		isOpened = ConfigController.Config.SelectionObjectPromt_Active,
	})

	local searchedTerm = Iris.State("")

	Iris.InputText({ "Search" }, { text = searchedTerm })

	Iris.Separator()

	Iris.Table({ 4 })

	Iris.Text("Name")
	Iris.NextColumn()
	Iris.Text("Class")
	Iris.NextColumn()
	Iris.Text("Kind")
	Iris.NextColumn()
	Iris.Text("")
	Iris.NextColumn()
	-- Iris.NextRow()
	-- Iris.End()

	-- Iris.Table({ 4 })
	Iris.Text("Workspace")
	Iris.NextColumn()
	Iris.Text("Frame")
	Iris.NextColumn()
	Iris.Text("PluginContainer")
	Iris.NextColumn()
	if Iris.Button("Select").clicked() then
		ConfigController.Config.SelectionObjectPromt_Selected:set(-1)
		ConfigController.Config.SelectionObjectPromt_Active:set(false)
		ConfigController.Config.SelectionObjectPromt_Selected:set(0)
	end
	Iris.NextColumn()
	Iris.End()
	-- Iris.NextRow()
	-- Iris.End()
	for index, object in ObjectController.Objects do
		if not (object.Object.Name:match(searchedTerm.value)) then
			continue
		end

		Iris.Table({ 4 })

		Iris.Text(object.Object.Name)
		Iris.NextColumn()
		Iris.Text(object.Class)
		Iris.NextColumn()
		Iris.Text(object.Kind)
		Iris.NextColumn()
		if Iris.Button("Select").clicked() then
			ConfigController.Config.SelectionObjectPromt_Selected:set(index)
			ConfigController.Config.SelectionObjectPromt_Active:set(false)
			ConfigController.Config.SelectionObjectPromt_Selected:set(0)
		end

		Iris.End()
	end

	Iris.End()
end
