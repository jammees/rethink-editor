if not plugin then
	return
end

local WIDGET_BUTTON_DEFAULT = "rbxassetid://13141195759"
local WIDGET_BUTTON_LOAD = "rbxassetid://13141195255"

local library = script.Parent.Library

local PluginFramework = require(library.PluginFramework).new(plugin, "Rethink Editor")

local UIController = nil
local isStarted = false
local widgetButton = PluginFramework._Toolbar:CreateButton(
	"__rethink_editor_widget_button",
	"Open/Close editor",
	WIDGET_BUTTON_DEFAULT,
	"Editor"
)

widgetButton.Click:Connect(function()
	if not isStarted then
		isStarted = true

		PluginFramework.LoadControllersDeep(script.Parent.Controllers, "Controller$")
		PluginFramework.Start()

		UIController = PluginFramework.GetController("UIController")

		UIController.WidgetToggled:Connect(function(newState: boolean)
			widgetButton:SetActive(newState)
		end)
	end

	UIController.Widget.Enabled = not UIController.Widget.Enabled
end)
