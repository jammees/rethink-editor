local library = script.Parent.Parent.Library

local Janitor = require(library.Janitor).new()
local UserInterfaceSystem = require(script.Parent.UserInterface)
local ObjectSystem = require(script.Parent.Object)

local actionMenu = nil

local ActionMenu = {}

-- Setting up the dropdown
function ActionMenu.Init(plugin: Plugin)
	actionMenu = plugin:CreatePluginMenu("__rethink_editor_create_menu", "Actions")
	actionMenu.Name = "Actions"

	actionMenu:AddNewAction("__rethink_editor_create_uibase", "New UIBase")
	actionMenu:AddNewAction("__rethink_editor_create_rigidbody", "New Rigidbody")
end

function ActionMenu.Start()
	Janitor:Add(UserInterfaceSystem.UI.Detector.MouseButton2Click:Connect(function()
		local selectedAction = actionMenu:ShowAsync()
		if selectedAction then
			if selectedAction.Text == "New UIBase" then
				ObjectSystem.New("UIBase")
			elseif selectedAction.Text == "New Rigidbody" then
				ObjectSystem.New("Rigidbody")
			end
		end
	end))
end

function ActionMenu.Destroy() end

return ActionMenu
