local DEFAULT_TEMPLATE = {
	WidgetTitle = "Rethink Editor",
	UITheme = "colorDark",
	DebugMode = false,

	MenuBarSizeY = 27,
	ExplorerSizeX = 300,
	PropertySizeX = 300,
	CreateNewObjectSize = Vector2.new(350, 165),
	SelectObjectSize = Vector2.new(350, 600),

	API = "",

	SelectionObjectPromt_Active = false,
	SelectionObjectPromt_Selected = 0,
}

local BLACKLIST = {
	"WidgetTitle",
	"SelectionObjectPromt_Active",
	"SelectionObjectPromt_Selected",
}

-- Finally, my hours haven't been wasted :)
local RoJSON = require(script.Parent.Parent.Library.RoJSON)
local Iris = require(script.Parent.Parent.Vendors["Iris-plugin"])
local IrisTypes = require(script.Parent.Parent.Vendors["Iris-plugin"].Types)

local PluginFramework = require(script.Parent.Parent.Library.PluginFramework)

local ConfigController = PluginFramework.CreateController("ConfigController")

function ConfigController:Init()
	self.Config = {} :: typeof(DEFAULT_TEMPLATE)
	self.Config = self.Framework._Plugin:GetSetting("__rethink_editor_config") or "[]"
	self.Config = RoJSON.Decode(self.Config)

	for key, value in self.Config do
		self.Config[key] = Iris.State(value)

		-- corruption check
		if typeof(self.Config[key]:get()) == typeof(DEFAULT_TEMPLATE[key]) then
			continue
		end

		-- warn(
		-- 	`{key} with value of {value} is corrupted: Types do not match; {typeof(self.Config[key]:get())} ~= {typeof(DEFAULT_TEMPLATE[key])}`
		-- )
		self.Config[key]:set(DEFAULT_TEMPLATE[key])
	end

	for key, value in DEFAULT_TEMPLATE do
		if self.Config[key] then
			continue
		end

		self.Config[key] = Iris.State(value)
	end
end

function ConfigController:Save()
	local rawConfig = {}

	for key, value in self.Config do
		if table.find(BLACKLIST, key) then
			continue
		end

		rawConfig[key] = value.value
	end

	self.Framework._Plugin:SetSetting("__rethink_editor_config", RoJSON.Encode(rawConfig))
end

function ConfigController:Stop()
	self:Save()
end

return ConfigController
