type PluginFramework = {
	__index: PluginFramework,

	_Plugin: Plugin,
	_Toolbar: PluginToolbar?,
	_Controllers: { [string]: PluginFrameworkController },

	ConfigValue: PluginFrameworkConfigValue,

	new: (plugin: Plugin, toolbarName: string) -> PluginFramework,
	ToolbarButton: (title: string, tip: string, imageID: string) -> PluginToolbarButton?,
	DockWidget: (title: string, sizeX: number, sizeY: number) -> DockWidgetPluginGui,
	CreateController: (controllerName: string) -> PluginFrameworkController,
	Start: () -> (),
	Stop: () -> (),
	LoadControllers: (path: Instance, nameRequirement: string?) -> (),
	LoadControllersDeep: (path: Instance, nameRequirement: string?) -> (),
	GetController: (controllerName: string) -> PluginFrameworkController?,
}

type PluginFrameworkController = {
	__index: PluginFrameworkController,

	Framework: PluginFramework,
	Name: string,

	new: (framework: PluginFramework, controllerName: string) -> PluginFrameworkController,
	Init: (self: PluginFrameworkController) -> ()?,
	Start: (self: PluginFrameworkController) -> ()?,
	Stop: (self: PluginFrameworkController) -> ()?,

	[any]: any,
}

type PluginFrameworkConfigValue = {
	__index: PluginFrameworkConfigValue,

	Value: any,
	_OnChangeCallbacks: { (value: any) -> () },

	new: (initialValue: any) -> PluginFrameworkConfigValue,
	Set: (self: PluginFrameworkConfigValue, newValue: any) -> (),
	Get: (self: PluginFrameworkConfigValue) -> any,
	OnChange: (self: PluginFrameworkConfigValue, callback: (value: any) -> ()) -> (),
	Destroy: (self: PluginFrameworkConfigValue) -> (),
}

local HTTPService = game:GetService("HttpService")

local Log = require(script.Parent.Log)

local ConfigValue = {} :: PluginFrameworkConfigValue
ConfigValue.__index = ConfigValue

function ConfigValue.new(initialValue: any)
	return setmetatable({ Value = initialValue, _OnChangeCallbacks = {} }, ConfigValue)
end

function ConfigValue.Set(self: PluginFrameworkConfigValue, newValue: any)
	self.Value = newValue

	for _, callback in self._OnChangeCallbacks do
		callback(self.Value)
	end
end

function ConfigValue.Get(self: PluginFrameworkConfigValue): any
	return self.Value
end

function ConfigValue.OnChange(self: PluginFrameworkConfigValue, callback: (value: any) -> ())
	table.insert(self._OnChangeCallbacks, callback)
end

function ConfigValue.Destroy(self: PluginFrameworkConfigValue)
	table.clear(self._OnChangeCallbacks)
	self.Value = nil
end

local PluginFrameController = {} :: PluginFrameworkController
PluginFrameController.__index = PluginFrameController

function PluginFrameController.new(framework: PluginFramework, controllerName: string)
	return setmetatable({ Framework = framework, Name = controllerName }, PluginFrameController)
end

local PluginFramework = {} :: PluginFramework
PluginFramework.__index = PluginFramework

PluginFramework._Plugin = nil :: Plugin?
PluginFramework._Toolbar = nil :: PluginToolbar?
PluginFramework._Controllers = nil :: { [string]: PluginFrameworkController }?

PluginFramework.ConfigValue = ConfigValue

function PluginFramework.new(plugin: Plugin, toolbarName: string?)
	PluginFramework._Plugin = plugin :: Plugin
	PluginFramework._Toolbar = toolbarName and plugin:CreateToolbar(toolbarName) or nil :: PluginToolbar?
	PluginFramework._Controllers = {} :: { [string]: PluginFrameworkController }

	PluginFramework._Plugin.Unloading:Connect(function()
		PluginFramework.Stop()
	end)

	return PluginFramework
end

function PluginFramework.ToolbarButton(title: string, tip: string, imageID: string): PluginToolbarButton?
	return PluginFramework._Toolbar:CreateButton(HTTPService:GenerateGUID(false), tip, imageID, title)
end

function PluginFramework.DockWidget(title: string, sizeX: number, sizeY: number): DockWidgetPluginGui
	local widget = PluginFramework._Plugin:CreateDockWidgetPluginGui(
		HTTPService:GenerateGUID(false),
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, sizeX, sizeY, sizeX, sizeY)
	)
	widget.Title = title
	widget.Name = title

	return widget
end

function PluginFramework.CreateController(controllerName: string): PluginFrameworkController
	local controller = PluginFrameController.new(PluginFramework, controllerName)

	PluginFramework._Controllers[controllerName] = controller

	return controller
end

function PluginFramework.Start()
	Log.Debug("Starting controllers...")

	local s = os.clock()

	for controllerName, controller: PluginFrameworkController in PluginFramework._Controllers do
		if not (typeof(controller.Init) == "function") then
			continue
		end

		controller.Init(controller)

		Log.Debug(`{controllerName} initiated!`)
	end

	for controllerName, controller: PluginFrameworkController in PluginFramework._Controllers do
		if not (typeof(controller.Start) == "function") then
			continue
		end

		task.spawn(function()
			controller.Start(controller)
			Log.Debug(`{controllerName} started!`)
		end)
	end

	Log.Debug(`Finished starting controllers in: {os.clock() - s}`)
end

function PluginFramework.Stop()
	for _, controller: PluginFrameworkController in PluginFramework._Controllers do
		if not (typeof(controller.Stop) == "function") then
			continue
		end

		task.spawn(function()
			controller.Stop(controller)
		end)
	end
end

function PluginFramework.LoadControllers(path: Instance, nameRequirement: string?)
	for _, object in path:GetChildren() do
		if object:IsA("ModuleScript") and object.Name:match(nameRequirement and nameRequirement or object.Name) then
			require(object)
		end
	end
end

function PluginFramework.LoadControllersDeep(path: Instance, nameRequirement: string?)
	for _, object in path:GetDescendants() do
		if object:IsA("ModuleScript") and object.Name:match(nameRequirement and nameRequirement or object.Name) then
			require(object)
		end
	end
end

function PluginFramework.GetController(controllerName: string)
	return PluginFramework._Controllers[controllerName]
end

export type Controller = PluginFrameworkController
export type ConfigValue = PluginFrameworkConfigValue

return PluginFramework
