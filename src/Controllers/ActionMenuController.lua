local Janitor = require(script.Parent.Parent.Library.Janitor)
local PluginFramework = require(script.Parent.Parent.Library.PluginFramework)

local ActionMenuController = PluginFramework.CreateController("ActionMenuController")

function ActionMenuController:Init()
	self._Janitor = Janitor.new()

	self.Action = self.Framework._Plugin:CreatePluginMenu("__rethink_editor_menu", "Actions")
	self.Action:AddNewAction("__rethink_editor_newobj", "Create new object")
end

function ActionMenuController:Start()
	local UIController = self.Framework.GetController("UIController")

	UIController.ClickDetector.MouseButton2Click:Connect(function()
		local choice = self.Action:ShowAsync()

		if not choice then
			return
		end

		if choice.Text == "Create new object" then
			UIController:COPromt()
		end
	end)
end

function ActionMenuController:Stop()
	self._Janitor:Destroy()
end

return ActionMenuController
