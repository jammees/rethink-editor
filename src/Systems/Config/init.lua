-- Handles the settings the plugin might use.

local Value = require(script.Value)

local SAVE_BLACKLIST = { "ui_Handler_IsFocused", "ui_Handler_IsFocused_Ref" }

local defaultRawValues = {
	man_Mode = 0,
	man_SnapToGrid = false,
	man_GridSize = 20,
	man_ShowAnchorPoint = true,
	ui_TopbarOffset = 130,
	ui_MenuSize = 30,
	ui_PropertySize = 250, -- 250
	ui_PropertyBase_TitleWidht = 0.5,
	ui_PropertyBase_HandlerWidht = 0.5,
	ui_Property_Handler_Padding_Spacer = 3,
	ui_Property_Handler_Padding_Left = 5,
	ui_Theme = "Dark",
	dev_DebugMode = true, -- enables the console
	dev_DebugMode_Level = 2, -- Listen for warnings and errors

	-- Non-Saved config
	ui_Handler_IsFocused = false,
	ui_Handler_IsFocused_Ref = nil,
}

local currentConfig = {}
local pluginPermission: Plugin = nil

local Config = {}

function Config.Init(plugin: Plugin)
	pluginPermission = plugin

	local cSave = plugin:GetSetting("__rethink_config_save")

	if not cSave then
		plugin:SetSetting("__rethink_config_save", defaultRawValues)

		cSave = defaultRawValues
	end

	-- Build from raw values
	Config.BuildFromRaw(cSave)

	return Config
end

function Config.GetRawValuesOf(tbl)
	local rawValues = {}

	for name, valueClass in tbl do
		if table.find(SAVE_BLACKLIST, name) then
			tbl[name] = nil

			continue
		end

		rawValues[name] = valueClass:get()
	end

	return rawValues
end

function Config.BuildFromRaw(rawValues)
	local rawSave = rawValues

	for name, value in rawSave do
		if defaultRawValues[name] == nil then
			--warn(`{name} with the value of {value} is obsolete!`)
			rawSave[name] = nil
			continue
		end

		currentConfig[name] = Value.new(value)
	end

	-- Check if there are settings missing from the raw data
	for name, value in defaultRawValues do
		if rawSave[name] == nil then
			if not table.find(SAVE_BLACKLIST, name) then
				rawSave[name] = value
			end

			currentConfig[name] = Value.new(value)
		end
	end

	pluginPermission:SetSetting("__rethink_config_save", rawSave)
end

function Config.Save()
	pluginPermission:SetSetting("__rethink_config_save", Config.GetRawValuesOf(currentConfig))
end

function Config.Get()
	return currentConfig
end

function Config.GetRawDefault()
	return defaultRawValues
end

return Config
