local library = script.Parent.Parent.Library

local Janitor = require(library.Janitor).new()
local UserInterfaceSystem = require(script.Parent.UserInterface)
local ObjectSystem = require(script.Parent.Object)
local LoggerSystem = require(script.Parent.LoggerV1)

local createObjectMenu = nil
local MB2actionMenu = nil

local ActionMenu = {}

-- Setting up the dropdown
function ActionMenu.Init(plugin: Plugin)
	createObjectMenu = plugin:CreatePluginMenu("__rethink_editor_create_menu", "Actions")
	createObjectMenu.Name = "Actions"

	local uibase = plugin:CreatePluginMenu("__rethink_editor_create_uibase", "New UIBase")
	local rigid = plugin:CreatePluginMenu("__rethink_editor_create_rigidbody", "New Rigidbody")

	-- Add classes UIBASE
	uibase:AddNewAction("__rethink_create_uibase_ViewportFrame", "ViewportFrame")
	uibase:AddNewAction("__rethink_create_uibase_Frame", "Frame")
	uibase:AddNewAction("__rethink_create_uibase_ScrollingFrame", "ScrollingFrame")
	uibase:AddNewAction("__rethink_create_uibase_ImageButton", "ImageButton")
	uibase:AddNewAction("__rethink_create_uibase_TextBox", "TextBox")
	uibase:AddNewAction("__rethink_create_uibase_TextButton", "TextButton")
	uibase:AddNewAction("__rethink_create_uibase_ImageLabel", "ImageLabel")
	uibase:AddNewAction("__rethink_create_uibase_TextLabel", "TextLabel")
	uibase:AddNewAction("__rethink_create_uibase_CanvasGroup", "CanvasGroup")

	-- Add classes RIGID
	rigid:AddNewAction("__rethink_create_rigid_ViewportFrame", "ViewportFrame")
	rigid:AddNewAction("__rethink_create_rigid_Frame", "Frame")
	rigid:AddNewAction("__rethink_create_rigid_ScrollingFrame", "ScrollingFrame")
	rigid:AddNewAction("__rethink_create_rigid_ImageButton", "ImageButton")
	rigid:AddNewAction("__rethink_create_rigid_TextBox", "TextBox")
	rigid:AddNewAction("__rethink_create_rigid_TextButton", "TextButton")
	rigid:AddNewAction("__rethink_create_rigid_ImageLabel", "ImageLabel")
	rigid:AddNewAction("__rethink_create_rigid_TextLabel", "TextLabel")
	rigid:AddNewAction("__rethink_create_rigid_CanvasGroup", "CanvasGroup")

	-- Finalize
	createObjectMenu:AddMenu(uibase)
	createObjectMenu:AddMenu(rigid)

	MB2actionMenu = plugin:CreatePluginMenu("__rethink_editor_mb2_action_menu", "Actions")
	MB2actionMenu.Name = "Actions"

	MB2actionMenu:AddNewAction("__rethink_editor_delete", "Delete")
end

function ActionMenu.Start()
	Janitor:Add(UserInterfaceSystem.UI.Detector.MouseButton2Click:Connect(function()
		local selectedAction = createObjectMenu:ShowAsync()
		if selectedAction then
			--[[ if selectedAction.Text == "New UIBase" then
				ObjectSystem.New("UIBase")
			elseif selectedAction.Text == "New Rigidbody" then
				ObjectSystem.New("Rigidbody")
			end ]]

			local actionId = selectedAction.ActionId
			local kind = string.find(actionId, "rigid") and "Rigidbody" or "UIBase"
			local class = string.split(actionId, "_")[#string.split(actionId, "_")]

			ObjectSystem.New(kind, class)
		end
	end))

	Janitor:Add(ObjectSystem.MB2Clicked:Connect(function(objectReference)
		local selectedAction = MB2actionMenu:ShowAsync()
		if selectedAction then
			if selectedAction.Text == "Delete" then
				LoggerSystem.Log("ActionMenu.lua", 1, `{objectReference.Object} cleaned up!`)

				objectReference.Cleanup:Destroy()
			end
		end
	end))
end

function ActionMenu.Destroy() end

return ActionMenu
