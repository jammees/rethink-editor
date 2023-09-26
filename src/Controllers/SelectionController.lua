local Types = require(script.Parent.Utility.Types)
local Signal = require(script.Parent.Parent.Vendors.GoodSignal)
local Janitor = require(script.Parent.Parent.Library.Janitor)
local PluginFramework = require(script.Parent.Parent.Library.PluginFramework)

---@module src.Controllers.ConfigController
local ConfigController = PluginFramework.GetController("ConfigController")
local SelectionController = PluginFramework.CreateController("SelectionController")

function SelectionController:Init()
	self._Janitor = Janitor.new()

	self.NewSelection = Signal.new()
	self.Triggered = Signal.new()
	self.SelectedObject = nil
end

function SelectionController:Start()
	local ObjectController = self.Framework.GetController("ObjectController")

	self._Janitor:Add(
		ObjectController.ObjectAdded:Connect(function(objectData: Types.ObjectData)
			self._Janitor:Add(objectData.Object.ClickDetector.MouseButton1Click:Connect(function()
				if not self.SelectedObject or self.SelectedObject ~= objectData then
					self.SelectedObject = objectData
					self.NewSelection:Fire()
					ConfigController.Config.Explorer_Selected_ID:set(
						ObjectController:GetIndexFromObject(objectData.Object)
					)
				end

				self.Triggered:Fire()
			end))
		end),
		"Disconnect"
	)
end

function SelectionController:Stop()
	self._Janitor:Destroy()
end

return SelectionController
