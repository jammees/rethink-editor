local DEFAULT_TEMPLATE = {
	WidgetTitle = "Rethink Editor",
	UITheme = "colorDark",
	DebugMode = false,

	MenuBarSizeY = 27,
	ExplorerSizeX = 300,
	PropertySizeX = 300,
	CreateNewObjectSize = Vector2.new(350, 165),

	API = "",
}

local BLACKLIST = {
	"WidgetTitle",
}

-- Finally, my hours haven't been wasted :)
local RoJSON = require(script.Parent.Parent.Library.RoJSON)
local Iris = require(script.Parent.Parent.Vendors["Iris-plugin"])
local IrisTypes = require(script.Parent.Parent.Vendors["Iris-plugin"].Types)

local PluginFramework = require(script.Parent.Parent.Library.PluginFramework)

local ConfigController = PluginFramework.CreateController("ConfigController")

function ConfigController:Init()
	self.Config = {} :: {
		WidgetTitle: IrisTypes.State,
		UITheme: IrisTypes.State,
		DebugMode: IrisTypes.State,

		MenuBarSizeY: IrisTypes.State,
		ExplorerSizeX: IrisTypes.State,
		PropertySizeX: IrisTypes.State,
		CreateNewObjectSize: IrisTypes.State,

		API: IrisTypes.State,
	}
	self.Config = self.Framework._Plugin:GetSetting("__rethink_editor_config") or "[]"
	self.Config = RoJSON.Decode(self.Config)

	for key, value in self.Config do
		self.Config[key] = Iris.State(value)
	end

	for key, value in DEFAULT_TEMPLATE do
		if self.Config[key] then
			continue
		end

		self.Config[key] = Iris.State(value)
	end
end

function ConfigController:Stop()
	local rawConfig = {}

	for key, value in self.Config do
		if table.find(BLACKLIST, key) then
			continue
		end

		rawConfig[key] = value.value
	end

	self.Framework._Plugin:SetSetting("__rethink_editor_config", RoJSON.Encode(rawConfig))
end

return ConfigController
