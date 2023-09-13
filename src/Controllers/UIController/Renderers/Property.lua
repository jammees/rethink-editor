local PluginFramework = require(script.Parent.Parent.Parent.Parent.Library.PluginFramework)
local Iris = require(script.Parent.Parent.Parent.Parent.Vendors["Iris-plugin"])
local Utility = require(script.Parent.Parent.Utility)

---@module src.Controllers.ConfigController
local ConfigController = PluginFramework.GetController("ConfigController")
---@module src.Controllers.ObjectController
local ObjectController = PluginFramework.GetController("ObjectController")
local Parser = ObjectController.Parser
local ParserTypes = Parser.Types
---@module src.Controllers.SelectionController
local SelectionController = PluginFramework.GetController("SelectionController")

local cachedProperties = {}

for name in Parser:GetClasses(Parser.Filter.Invert(Parser.Filter.Deprecated)) do
	cachedProperties[name] = Parser:GetProperties(name, Parser.Filter.Invert(Parser.Filter.Deprecated))
end

local function StringifyTable(v, spaces, usesemicolon, depth)
	if type(v) ~= "table" then
		return tostring(v)
	elseif not next(v) then
		return "{}"
	end

	spaces = spaces or 4
	depth = depth or 1

	local space = (" "):rep(depth * spaces)
	local sep = usesemicolon and ";" or ","
	local concatenationBuilder = { "{" }

	for k, x in next, v do
		table.insert(
			concatenationBuilder,
			("\n%s[%s] = %s%s"):format(
				space,
				type(k) == "number" and tostring(k) or ('"%s"'):format(tostring(k)),
				StringifyTable(x, spaces, usesemicolon, depth + 1),
				sep
			)
		)
	end

	local s = table.concat(concatenationBuilder)
	return ("%s\n%s}"):format(s:sub(1, -2), space:sub(1, -spaces - 1))
end

return function()
	local sizeState = Iris.ComputedState(Utility.WidgetSize, function(firstState: Vector2)
		return Vector2.new(
			ConfigController.Config.PropertySizeX.value,
			firstState.Y - ConfigController.Config.MenuBarSizeY.value
		)
	end)

	local positionState = Iris.ComputedState(ConfigController.Config.MenuBarSizeY, function(firstState: number)
		return Vector2.new(Utility.WidgetSize:get().X - ConfigController.Config.PropertySizeX:get(), firstState)
	end)

	if not SelectionController.SelectedObject then
		return
	end

	local searchString = Iris.State("")

	Iris.Window({ "Debug" })
	-- for class, properties in cachedProperties do
	-- 	Iris.Tree({ class })
	-- 	for _, propertyData: ParserTypes.Property in properties do
	-- 		Iris.Text({
	-- 			`[{propertyData.Security.Read}, {propertyData.Security.Write}] {propertyData.Name} = {propertyData.ValueType.Category}/{propertyData.ValueType.Name}`,
	-- 		})
	-- 	end
	-- 	Iris.End()
	-- end
	Iris.InputText({ "Search" }, { text = searchString })

	Iris.Separator()

	for class: string, properties in cachedProperties do
		if not (class:match(searchString:get())) then
			continue
		end

		Iris.Tree({ class })

		for propertyName, data: ParserTypes.Property in properties do
			Iris.Tree({ propertyName })

			Iris.TextWrapped({ StringifyTable(data) })
			-- 	for dataName, dataValue in data do
			-- 		Iris.SameLine()

			-- 		if typeof(dataValue) == "table" then
			-- 			for i, v in dataValue do
			-- 				Iris.Text({ i })
			-- 				Iris.Text({ tostring(v) })
			-- 			end

			-- 			continue
			-- 		end

			-- 		Iris.Text({ dataName })
			-- 		Iris.Text({ tostring(dataValue) })

			-- 		Iris.End()
			-- 	end

			Iris.End()
		end

		Iris.End()
	end

	Iris.End()

	Iris.Window({
		"Property",
		[Iris.Args.Window.NoCollapse] = true,
		[Iris.Args.Window.NoClose] = true,
		[Iris.Args.Window.NoMove] = true,
		[Iris.Args.Window.NoScrollbar] = true,
		[Iris.Args.Window.NoResize] = true,
	}, { size = sizeState, position = positionState })

	-- local propertyStates = {}

	--[[
		int
		float
		bool
		Color3
		UDim2
		Vector2
		string
		Enum
	]]
	for _, propertyData: ParserTypes.Property in cachedProperties[SelectionController.SelectedObject.Class] do
		Iris.SameLine()

		if propertyData.ValueType.Name == "int" then
			Iris.InputNum(
				{ propertyData.Name, [Iris.Args.InputNum.Format] = "%d" },
				{ number = SelectionController.SelectedObject[propertyData.Name] }
			)
		end

		if propertyData.ValueType.Name == "float" then
			Iris.InputNum(
				{ propertyData.Name, [Iris.Args.InputNum.Format] = "%f" },
				{ number = SelectionController.SelectedObject[propertyData.Name] }
			)
		end

		if propertyData.ValueType.Name == "bool" then
			Iris.Checkbox({ propertyData.Name }, { isChecked = SelectionController.SelectedObject[propertyData.Name] })
		end

		if propertyData.ValueType.Name == "Color3" then
			Iris.InputColor3({ propertyData.Name }, { color = SelectionController.SelectedObject[propertyData.Name] })
		end

		if propertyData.ValueType.Name == "Vector2" then
			Iris.InputVector2({ propertyData.Name }, { number = SelectionController.SelectedObject[propertyData.Name] })
		end

		if propertyData.ValueType.Name == "UDim2" then
			Iris.InputUDim2({ propertyData.Name }, { number = SelectionController.SelectedObject[propertyData.Name] })
		end

		if propertyData.ValueType.Name == "string" then
			Iris.InputText({ propertyData.Name }, { text = SelectionController.SelectedObject[propertyData.Name] })
		end

		if propertyData.ValueType.Name == "Color3" then
			Iris.InputColor3({ propertyData.Name }, { color = SelectionController.SelectedObject[propertyData.Name] })
		end

		if propertyData.ValueType.Category == "Enum" then
			Iris.InputEnum({ propertyData.Name }, {}, Enum[propertyData.ValueType.Name])
		end

		Iris.End()
	end

	Iris.End()
end
