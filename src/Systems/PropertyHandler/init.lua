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
	[x] Vector2
	[x] string
	[ ] AutomaticSize
	[x] UDim2
	[ ] SelectionBehavior
	[ ] LocalizationTable
	[ ] Rect
	[ ] ScaleType
	[ ] Content
	[ ] ResamplerMode
	[ ] ButtonStyle
	[ ] Camera
	[x] Vector3
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
local propertyHandlers = script.Parent.UserInterface.Handlers.Property

local SelectorSystem = require(script.Parent.Selector)
local UserInterfaceSystem = require(script.Parent.UserInterface)
local ObjectSystem = require(script.Parent.Object)
local LoggerSystem = require(script.Parent.LoggerV1)

local Janitor = require(library.Janitor).new()
local DumpParser = require(library["dump-parser-0.1.1"])
local FetchDump = require(library["dump-parser-0.1.1"].FetchDump)
local Util = require(script.Util)
local ICON_SET = require(script.Parent.UserInterface.ICON_SET)

local serverDump = nil

local H_propertyBase = require(UserInterfaceSystem.Handlers.PropertyBase)
local H_propertyCategory = require(UserInterfaceSystem.Handlers.PropertyCategory)

local handlers = {
	Checkbox = require(propertyHandlers.Checkbox),
	NumberField = require(propertyHandlers.NumberField),
	ColorField = require(propertyHandlers.ColorField),
	StringField = require(propertyHandlers.StringField),
	Udim2Field = require(propertyHandlers.Udim2Field),
	Vector3Field = require(propertyHandlers.Vector3Field),
	Vector2Field = require(propertyHandlers.Vector2Field),
	EnumDropdown = require(propertyHandlers.EnumDropdown),
}

local propertyWindow = nil

local handlerCategories = {}
local cleanupJanitor = Janitor.new()

local PropertyHandler = {}

function PropertyHandler.Clear()
	cleanupJanitor:Cleanup()

	handlerCategories = {}
end

function PropertyHandler.GetHandlerDef(value: string, item: any)
	if value == "bool" or value == "boolean" then
		return "Checkbox"
	elseif value == "int" or value == "float" or value == "number" then
		return "NumberField"
	elseif value == "string" then
		return "StringField"
	elseif value == "Color3" then
		return "ColorField"
	elseif value == "UDim2" then
		return "Udim2Field"
	elseif value == "Vector3" then
		return "Vector3Field"
	elseif value == "Vector2" then
		return "Vector2Field"
	end

	if typeof(item) == "EnumItem" then
		return "EnumDropdown"
	end

	warn(value)

	--print(`{value}({typeof(value)}) has no handler!`)

	return nil
end

function PropertyHandler.GetHandler(valueType: string)
	return handlers[PropertyHandler.GetHandlerDef(valueType)]
end

function PropertyHandler.LoadFrom<OBJ>(object: OBJ)
	local objectProperties = serverDump:GetProperties(object, DumpParser.Filter.Invert(DumpParser.Filter.ReadOnly))

	-- do stuffs
	for propName, data: Property in objectProperties do
		local handlerDef = PropertyHandler.GetHandlerDef(data.ValueType.Name, object[propName])

		if not handlerDef then
			continue
		end

		if not handlerCategories[data.Category] then
			local categoryClass = H_propertyCategory.new({ Name = data.Category, Janitor = cleanupJanitor })
			categoryClass:GetUI().Parent = propertyWindow.Contents
			handlerCategories[data.Category] = categoryClass
		end

		local base = H_propertyBase({
			Property = propName,
			Handler = handlers[handlerDef].new({
				Object = object,
				InitialValue = object[propName],
				Range = Util.GetRangeFromProperty(propName),
				Janitor = cleanupJanitor,
				Property = propName,
				OnValueChange = function(newValue: any)
					object[propName] = newValue
					ObjectSystem.GetFromObject(object).ExportData.Properties[propName] = newValue

					LoggerSystem.Log(
						"PropertyHandler.lua",
						1,
						`{handlerDef}.OnValueChanged => {object}.{propName} = {newValue}`
					)
				end,
			}),
		})

		cleanupJanitor:Add(base)

		handlerCategories[data.Category]:Add(base)
	end
end

function PropertyHandler.Init(plugin: Plugin, editorButton: PluginToolbarButton)
	-- Set icon to download one
	editorButton.Icon = ICON_SET.editor_button_download

	-- Get setting related to the dump
	-- if the hash does not match rebuild the dump
	-- if it does use that dump
	local savedDump = plugin:GetSetting("__rethink_property_dump")

	local success, latestHashVersion = pcall(function()
		return FetchDump.fetchLatestVersionHash()
	end)

	-- Overwrite the latestHashVersion to use the one we saved
	if not success then
		latestHashVersion = savedDump.HashVersion
	end

	if savedDump == nil or savedDump.HashVersion ~= latestHashVersion then
		local rawDump = DumpParser.fetchRawDump(latestHashVersion)
		serverDump = DumpParser.new(rawDump)
		plugin:SetSetting("__rethink_property_dump", {
			Dump = rawDump,
			HashVersion = latestHashVersion,
		})

		warn("[Rethink Editor] Saved dump was corrupted or is outdated! Updated dump to the latest one.")

		return
	end

	serverDump = DumpParser.new(savedDump.Dump)

	editorButton.Icon = ICON_SET.editor_button_default
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
