local systems = script.Parent.Systems

local UserInterfaceSystem = require(systems.UserInterface)
local ActionMenuSystem = require(systems.ActionMenu)
local MouseSystem = require(systems.Mouse)
local SelectorSystem = require(systems.Selector)
local ManipulationSystem = require(systems.Manipulation)

local toolbar = plugin:CreateToolbar("Editor")
local editorButton = toolbar:CreateButton("__rethink_editor_button", "Opens/Closes the editor.", "rbxassetid://0")

local window = plugin:CreateDockWidgetPluginGui(
	"__rethink_editor_window",
	DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 1000, 500, 500, 250)
)
window.Name = "RethinkEditor"

-- Initialize systems
ActionMenuSystem.Init(plugin)

local isOpen = false

editorButton.Click:Connect(function()
	isOpen = not isOpen

	if isOpen then
		UserInterfaceSystem.Start(window)
		ActionMenuSystem.Start()
		MouseSystem.Start()
		SelectorSystem.Start()
		ManipulationSystem.Start()

		window.Enabled = true

		return
	end

	window.Enabled = false

	UserInterfaceSystem.Destroy()
	ActionMenuSystem.Destroy()
	MouseSystem.Destroy()
	SelectorSystem.Destroy()
	ManipulationSystem.Destroy()
end)
