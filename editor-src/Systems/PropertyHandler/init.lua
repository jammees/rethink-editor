type Property = {
	MemberType: "Property",
	Category: string,
	Name: string,
	Security: {
		Read: string,
		Write: string,
	},
	Serialization: {
		CanLoad: boolean,
		CanSave: boolean,
	},
	Tags: { string }?,
	ThreadSafety: string,
	ValueType: {
		Category: string,
		Name: string,
	},
}

--[[
	TODO: List of all of the handlers needed

	[x] Class selection
	[x] int
	[x] float
	[x] bool
	[ ] SizeConstraint
	[ ] GuiObject
	[x] Color3
	[ ] BorderMode
	[ ] Vector2
	[ ] string
	[ ] AutomaticSize
	[ ] UDim2
	[ ] SelectionBehavior
	[ ] LocalizationTable
	[ ] Rect
	[ ] ScaleType
	[ ] Content
	[ ] ResamplerMode
	[ ] ButtonStyle
	[ ] Camera
	[ ] Vector3
	[ ] TextTruncate
	[ ] TextYAlignment
	[ ] Font
	[ ] TextXAlignment
	[ ] FrameStyle
	[ ] ScrollingDirection
	[ ] ScrollBarInset
	[ ] ElasticBehavior
	[ ] VerticalScrollBarPosition

]]

local library = script.Parent.Parent.Library

local SelectorSystem = require(script.Parent.Selector)
local UserInterfaceSystem = require(script.Parent.UserInterface)
local ObjectSystem = require(script.Parent.Object)

local Janitor = require(library.Janitor).new()
local DumpParser = require(library["dump-parser-0.1.1"])
local Util = require(script.Util)

local serverDump = DumpParser.fetchFromServer()

local H_propertyBase = require(UserInterfaceSystem.Handlers.propertyBase)

local handlers = {
	H_checkbox = require(UserInterfaceSystem.Handlers.checkbox),
	H_numberField = require(UserInterfaceSystem.Handlers.numberField),
	H_colorField = require(UserInterfaceSystem.Handlers.colorField),
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
	if value == "bool" then
		return "H_checkbox"
	elseif value == "int" or value == "float" then
		return "H_numberField"
	elseif value == "Color3" then
		return "H_colorField"
	elseif value == "Instance" then
		return nil
	elseif value == "Vector2" then
		return nil
	elseif value == "UDim2" then
		return nil
	end

	return nil
end

function PropertyHandler.LoadFrom<OBJ>(object: OBJ)
	local objectProperties = serverDump:GetProperties(object, DumpParser.Filter.Invert(DumpParser.Filter.ReadOnly))

	-- do stuffs
	for propName, data: Property in objectProperties do
		local handlerDef = PropertyHandler.GetHandlerDef(data.ValueType.Name)

		if not handlerDef then
			continue
		end

		local base = H_propertyBase({
			Property = propName,
			Handler = handlers[handlerDef]({
				--Title = propName,
				Object = object,
				InitialState = object[propName],
				InitialValue = object[propName],
				OnStateChange = function(newValue: any)
					object[propName] = newValue
					ObjectSystem.GetFromObject(object).ExportData.Properties[propName] = newValue
				end,
				Range = Util.GetRangeFromProperty(propName),
			}),
		})

		base.Parent = propertyWindow.Contents

		table.insert(loadedHandlers, base)
	end
end

function PropertyHandler.Start()
	propertyWindow = UserInterfaceSystem.UI.Editor.Property

	Janitor:Add(SelectorSystem.Triggered:Connect(function()
		PropertyHandler.Clear()
		PropertyHandler.LoadFrom(SelectorSystem.Selected)
	end))

	Janitor:Add(UserInterfaceSystem.UI.Detector.MouseButton1Click:Connect(function()
		PropertyHandler.Clear()
	end))
end

function PropertyHandler.Destroy()
	Janitor:Cleanup()
end

return PropertyHandler
