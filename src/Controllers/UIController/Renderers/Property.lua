local PluginFramework = require(script.Parent.Parent.Parent.Parent.Library.PluginFramework)
local IrisTypes = require(script.Parent.Parent.Parent.Parent.Vendors["Iris-plugin"].Types)

---@module src.Controllers.ConfigController
local ConfigController = PluginFramework.GetController("ConfigController")
---@module src.Controllers.ObjectController
local ObjectController = PluginFramework.GetController("ObjectController")
local Parser = ObjectController.Parser
local ParserTypes = Parser.Types
---@module src.Controllers.SelectionController
local SelectionController = PluginFramework.GetController("SelectionController")
---@module src.Controllers.UIController
local UIController = PluginFramework.GetController("UIController")

local cachedProperties = {}
local objectPropertyStates = {}
local propertyWidgets = {}

local doUpdate = false

-- Refreshes the properties
SelectionController.NewSelection:Connect(function()
	doUpdate = false

	for index, widget: IrisTypes.Widget in propertyWidgets do
		UIController.Iris.Internal._DiscardWidget(widget)
		table.remove(propertyWidgets, index)
	end

	for index, state: IrisTypes.State in objectPropertyStates do
		table.clear(state.ConnectedFunctions)
		table.clear(state.ConnectedWidgets)
		objectPropertyStates[index] = nil
	end

	-- For some reason if there is no delay after discarding every
	-- widget then Iris will skip some objects
	-- when displaying the properties
	task.wait()

	doUpdate = true
end)

for name in Parser:GetClasses(Parser.Filter.Invert(Parser.Filter.Deprecated)) do
	cachedProperties[name] = Parser:GetProperties(
		name,
		Parser.Filter.Any(Parser.Filter.Invert(Parser.Filter.Deprecated), Parser.Filter.Invert(Parser.Filter.ReadOnly))
	)
end

return function(Iris: IrisTypes.Iris)
	local sizeState = Iris.ComputedState(UIController.WidgetSize, function(firstState: Vector2)
		return Vector2.new(
			ConfigController.Config.PropertySizeX.value,
			firstState.Y - ConfigController.Config.MenuBarSizeY.value
		)
	end)

	local positionState = Iris.ComputedState(ConfigController.Config.MenuBarSizeY, function(firstState: number)
		return Vector2.new(UIController.WidgetSize:get().X - ConfigController.Config.PropertySizeX:get(), firstState)
	end)

	Iris.ComputedState(ConfigController.Config.PropertySizeX, function(firstState: number)
		sizeState:set(
			Vector2.new(firstState, UIController.WidgetSize.value.Y - ConfigController.Config.MenuBarSizeY.value)
		)
		positionState:set(
			Vector2.new(UIController.WidgetSize:get().X - firstState, ConfigController.Config.MenuBarSizeY.value)
		)
	end)

	Iris.ComputedState(UIController.WidgetSize, function(firstState)
		positionState:set(
			Vector2.new(
				firstState.X - ConfigController.Config.PropertySizeX:get(),
				ConfigController.Config.MenuBarSizeY.value
			)
		)
	end)

	Iris.Window({
		"Property",
		[Iris.Args.Window.NoCollapse] = true,
		[Iris.Args.Window.NoClose] = true,
		[Iris.Args.Window.NoMove] = true,
		[Iris.Args.Window.NoScrollbar] = true,
		[Iris.Args.Window.NoResize] = true,
	}, { size = sizeState, position = positionState })

	-- local propertyStates = {}

	-- --[[
	-- 	int
	-- 	float
	-- 	bool
	-- 	Color3
	-- 	UDim2
	-- 	Vector2
	-- 	string
	-- 	Enum
	-- ]]
	local function GetPropertyStateAndAttach(propertyName: string)
		if objectPropertyStates[propertyName] then
			local state = objectPropertyStates[propertyName]
			state:set(SelectionController.SelectedObject.Object[propertyName])
			return state
		end

		objectPropertyStates[propertyName] = Iris.State(SelectionController.SelectedObject.Object[propertyName])

		objectPropertyStates[propertyName]:onChange(function(newValue: any)
			SelectionController.SelectedObject.Object[propertyName] = newValue
		end)

		return objectPropertyStates[propertyName]
	end

	if not SelectionController.SelectedObject or not doUpdate then
		Iris.End()

		return
	end

	-- Refresh cache
	table.clear(propertyWidgets)

	for _, propertyData: ParserTypes.Property in cachedProperties[SelectionController.SelectedObject.Class] do
		table.insert(
			propertyWidgets,
			Iris.Table({
				2,
				[Iris.Args.Table.RowBg] = true,
				[Iris.Args.Table.BordersInner] = false,
				[Iris.Args.Table.BordersOuter] = false,
			})
		)
		table.insert(propertyWidgets, Iris.Text({ propertyData.Name }))
		Iris.NextColumn()

		Iris.PushConfig({ ContentWidth = UDim.new(1, 0) })

		if propertyData.ValueType.Name == "bool" then
			table.insert(
				propertyWidgets,
				Iris.Checkbox({ "" }, { isChecked = GetPropertyStateAndAttach(propertyData.Name) })
			)
			Iris.PopConfig()
			Iris.End()
			continue
		end

		if propertyData.ValueType.Name == "int" then
			table.insert(
				propertyWidgets,
				Iris.InputNum(
					{ "", [Iris.Args.InputNum.Format] = "%d" },
					{ number = GetPropertyStateAndAttach(propertyData.Name) }
				)
			)
			Iris.PopConfig()
			Iris.End()
			continue
		end

		if propertyData.ValueType.Name == "float" then
			table.insert(
				propertyWidgets,
				Iris.InputNum(
					{ "", [Iris.Args.InputNum.Format] = "%.3f" },
					{ number = GetPropertyStateAndAttach(propertyData.Name) }
				)
			)
			Iris.PopConfig()
			Iris.End()
			continue
		end

		if propertyData.ValueType.Name == "UDim2" then
			table.insert(
				propertyWidgets,
				Iris.InputUDim2({ "" }, { number = GetPropertyStateAndAttach(propertyData.Name) })
			)
			Iris.PopConfig()
			Iris.End()
			continue
		end

		if propertyData.ValueType.Name == "Vector2" then
			table.insert(
				propertyWidgets,
				Iris.InputVector2({ "" }, { number = GetPropertyStateAndAttach(propertyData.Name) })
			)
			Iris.PopConfig()
			Iris.End()
			continue
		end

		if propertyData.ValueType.Name == "string" then
			table.insert(
				propertyWidgets,
				Iris.InputText({ "" }, { text = GetPropertyStateAndAttach(propertyData.Name) })
			)
			Iris.PopConfig()
			Iris.End()
			continue
		end

		if propertyData.ValueType.Category == "Enum" then
			table.insert(
				propertyWidgets,
				Iris.ComboEnum(
					{ "" },
					{ index = GetPropertyStateAndAttach(propertyData.Name) },
					Enum[propertyData.ValueType.Name]
				)
			)
			Iris.PopConfig()
			Iris.End()
			continue
		end

		table.insert(
			propertyWidgets,
			Iris.Text({ "Not implemented :(", [Iris.Args.Text.Color] = Color3.fromRGB(105, 105, 105) })
		)
		Iris.PopConfig()
		Iris.End()
	end

	Iris.End()
end
