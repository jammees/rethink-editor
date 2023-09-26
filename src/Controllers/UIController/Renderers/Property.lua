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
local searchedTerm = UIController.Iris.State("")

local function RedrawWidgets()
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
end

-- Hear me out on this one:
-- For some reason I have to do this terribleness if I want
-- to have a search bar for properties. If I would not do this,
-- widgets would just disappear and overall would not position
-- properly. This goes for selecting a new object also.
searchedTerm:onChange(function()
	doUpdate = false

	task.wait()

	RedrawWidgets()
end)

-- Refreshes the properties
SelectionController.NewSelection:Connect(function()
	RedrawWidgets()
end)

for name in Parser:GetClasses(Parser.Filter.Invert(Parser.Filter.Deprecated)) do
	cachedProperties[name] = Parser:GetProperties(
		name,
		-- Parser.Filter.Any(Parser.Filter.Invert(Parser.Filter.Deprecated), Parser.Filter.Invert(Parser.Filter.ReadOnly))
		Parser.Filter.Any(Parser.Filter.Invert(Parser.Filter.ReadOnly), Parser.Filter.Deprecated)
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

	Iris.InputText({ "Search" }, { text = searchedTerm })
	Iris.Separator()

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

			if propertyName == "Parent" then
				return
			end

			SelectionController.SelectedObject.Properties[propertyName] = newValue
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
		if not (string.lower(propertyData.Name):match(string.lower(searchedTerm.value))) then
			continue
		end

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
				Iris.InputVector2(
					{ "", [Iris.Args.InputVector2.Format] = "%.3f" },
					{ number = GetPropertyStateAndAttach(propertyData.Name) }
				)
			)
			Iris.PopConfig()
			Iris.End()
			continue
		end

		if propertyData.ValueType.Name == "string" or propertyData.ValueType.Name == "Content" then
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

		if propertyData.ValueType.Name == "Color3" then
			table.insert(
				propertyWidgets,
				Iris.InputColor3({ "" }, { color = GetPropertyStateAndAttach(propertyData.Name) })
			)
			Iris.PopConfig()
			Iris.End()
			continue
		end

		if propertyData.ValueType.Name == "Rect" then
			table.insert(
				propertyWidgets,
				Iris.InputRect({ "" }, { number = GetPropertyStateAndAttach(propertyData.Name) })
			)
			Iris.PopConfig()
			Iris.End()
			continue
		end

		if propertyData.ValueType.Category == "Class" then
			local selected = Iris.State()
			local button = Iris.Button({ tostring(GetPropertyStateAndAttach(propertyData.Name).value) })
			if button.clicked() then
				selected:set(button.ID)
				ConfigController.Config.SelectionObjectPromt_Selected:onChange(function(objectIndex)
					print(objectIndex)
					local selectedObject = ObjectController.Objects[objectIndex]
					print(selectedObject.Object)
					SelectionController.SelectedObject.Object[propertyData.Name] = selectedObject.Object
					table.clear(ConfigController.Config.SelectionObjectPromt_Selected.ConnectedFunctions)
				end)
				ConfigController.Config.SelectionObjectPromt_Active:set(true)
			end
			table.insert(propertyWidgets, button)
			Iris.PopConfig()
			Iris.End()
			continue
		end

		table.insert(
			propertyWidgets,
			Iris.Text({
				`{propertyData.ValueType.Name} ({propertyData.ValueType.Category})`,
				[Iris.Args.Text.Color] = Color3.fromRGB(105, 105, 105),
			})
		)
		Iris.PopConfig()
		Iris.End()
	end

	Iris.End()
end
