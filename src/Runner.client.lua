-- Prevent the plugin running if it's not in the studio environment
if game:GetService("RunService"):IsRunning() then
	return warn("Editor can only run in studio!")
end

local systems = script.Parent.Systems

local UserInterfaceSystem = require(systems.UserInterface)
local ActionMenuSystem = require(systems.ActionMenu)
local MouseSystem = require(systems.Mouse)
local SelectorSystem = require(systems.Selector)
local ManipulationSystem = require(systems.Manipulation)
local LoggerSystem = require(systems.Logger)
local PropertyHandlerSystem = require(systems.PropertyHandler)

local ICON_SET = require(systems.UserInterface.ICON_SET)

local toolbar = plugin:CreateToolbar("Editor")

local window = plugin:CreateDockWidgetPluginGui(
	"__rethink_editor_window",
	DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 1000, 500, 500, 250)
)
window.Name = "RethinkEditor"
window.Title = "Rethink Editor v0.1.0"

-- Initialize the button after the dump has been loaded
local editorButton =
	toolbar:CreateButton("__rethink_editor_button", "Opens/Closes the editor.", ICON_SET.editor_button_default, "Open")
editorButton.ClickableWhenViewportHidden = true

-- Initialize systems
ActionMenuSystem.Init(plugin)
LoggerSystem.Init(plugin)
ManipulationSystem.Init()
PropertyHandlerSystem.Init(plugin, editorButton)

local isOpen = false

editorButton.Click:Connect(function()
	isOpen = not isOpen

	if isOpen then
		UserInterfaceSystem.Start(window)
		ActionMenuSystem.Start()
		MouseSystem.Start()
		SelectorSystem.Start()
		ManipulationSystem.Start()
		LoggerSystem.Start()
		PropertyHandlerSystem.Start()

		window.Enabled = true

		LoggerSystem.Log("Successfully initialized systems!")

		return
	end

	window.Enabled = false
	LoggerSystem.ToggleConsoleState(false)

	UserInterfaceSystem.Destroy()
	ActionMenuSystem.Destroy()
	MouseSystem.Destroy()
	SelectorSystem.Destroy()
	ManipulationSystem.Destroy()
	LoggerSystem.Destroy()
	PropertyHandlerSystem.Destroy()
end)
