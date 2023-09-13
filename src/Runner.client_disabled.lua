-- Prevent the plugin running if it's not in the studio environment
if game:GetService("RunService"):IsRunning() then
	return warn("Editor can only run in studio!")
end

local systems = script.Parent.Systems

require(systems.Config).Init(plugin) -- Even if it looks weird that I initiate it here, this needs to have priority
local UserInterfaceSystem = require(systems.UserInterface)
local ActionMenuSystem = require(systems.ActionMenu)
local MouseSystem = require(systems.Mouse)
local SelectorSystem = require(systems.Selector)
local ManipulationSystem = require(systems.Manipulation)
local LoggerSystem = require(systems.LoggerV1)
local PropertyHandlerSystem = require(systems.PropertyHandler)
local ObjectSystem = require(systems.Object)
local SettingsHandlerSystem = require(systems.SettingsHandler)

local ICON_SET = require(systems.UserInterface.ICON_SET)

local toolbar = plugin:CreateToolbar("Editor")

local window = plugin:CreateDockWidgetPluginGui(
	"__rethink_editor_window",
	DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 1000, 500, 500, 250)
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
SettingsHandlerSystem.Init(plugin)

local isOpen = false

local function Start()
	LoggerSystem.Start()
	UserInterfaceSystem.Start(window)
	ActionMenuSystem.Start()
	MouseSystem.Start()
	SelectorSystem.Start()
	ManipulationSystem.Start()
	PropertyHandlerSystem.Start()
	SettingsHandlerSystem.Start()
	ObjectSystem.Start()

	ObjectSystem.LoadObjects()
end

local function Destroy()
	UserInterfaceSystem.Destroy()
	ActionMenuSystem.Destroy()
	MouseSystem.Destroy()
	SelectorSystem.Destroy()
	ManipulationSystem.Destroy()
	LoggerSystem.Destroy()
	PropertyHandlerSystem.Destroy()
	SettingsHandlerSystem.Destroy()
	ObjectSystem.Destroy()
end

editorButton.Click:Connect(function()
	isOpen = not isOpen

	if isOpen then
		Start()

		window.Enabled = true

		LoggerSystem.Log("Runner.client.lua", 1, "Successfully initialized systems!")

		return
	end

	Destroy()

	window.Enabled = false
	LoggerSystem.ToggleConsoleState(false)
end)

window:GetPropertyChangedSignal("Enabled"):Connect(function()
	local state = window.Enabled
	isOpen = state

	if not isOpen then
		editorButton:SetActive(false)
		LoggerSystem.ToggleConsoleState(false, true)
		Destroy()
	else
		editorButton:SetActive(true)
	end
end)
