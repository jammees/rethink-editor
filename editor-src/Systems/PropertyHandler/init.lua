local library = script.Parent.Parent.Library

local SelectorSystem = require(script.Parent.Selector)
local UserInterfaceSystem = require(script.Parent.UserInterface)

local Janitor = require(library.Janitor).new()
local DefaultProperties = require(script.Parent.Object.DefaultProperties)

local handlers = {
	H_createPropertyCheckbox = require(UserInterfaceSystem.Handlers.createPropertyCheckbox),
}

local propertyWindow = nil

local loadedHandlers = {}

local PropertyHandler = {}

function PropertyHandler.Clear()
	for _, handler in loadedHandlers do
		handler:Destroy()
	end
end

function PropertyHandler.GetHandlerDef(value: string)
	if typeof(value) == "boolean" then
		return "H_createPropertyCheckbox"
	end
	return nil
end

function PropertyHandler.LoadFrom<OBJ>(object: OBJ)
	-- do stuffs
	for propName, defaultValue in DefaultProperties[object.ClassName] do
		local handlerDef = PropertyHandler.GetHandlerDef(defaultValue)

		if not handlerDef then
			continue
		end

		local handler = handlers[handlerDef]({
			Property = propName,
			Object = object,
			InitialState = object[propName],
		})

		handler.Parent = propertyWindow.Contents

		table.insert(loadedHandlers, handler)
	end
end

function PropertyHandler.Start()
	propertyWindow = UserInterfaceSystem.UI.Editor.Property

	Janitor:Add(SelectorSystem.SelectionChanged:Connect(function()
		PropertyHandler.Clear()
		PropertyHandler.LoadFrom(SelectorSystem.Selected)
	end))
end

function PropertyHandler.Destroy()
	Janitor:Cleanup()
end

return PropertyHandler
