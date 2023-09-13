local PluginFramework = require(script.Parent.Parent.Parent.Library.PluginFramework)
local Iris = require(script.Parent.Parent.Parent.Vendors["Iris-plugin"])
local Types = require(script.Parent.Types)

local UIController = PluginFramework.GetController("UIController")

local Utility = {} :: Types.Utility

Utility.WidgetSize = Iris.State(UIController.Widget.AbsoluteSize)

UIController.Widget:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	Utility.WidgetSize:set(UIController.Widget.AbsoluteSize)
end)

Utility.CreateNewObjectActive = Iris.State(false)

return Utility
