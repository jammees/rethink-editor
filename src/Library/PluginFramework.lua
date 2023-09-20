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

local PluginBootDisplay = {}
PluginBootDisplay.__index = PluginBootDisplay

function PluginBootDisplay.new(PluginFramework: PluginFramework)
	local self = setmetatable({}, PluginBootDisplay)

	self.Widget = PluginFramework._Plugin:CreateDockWidgetPluginGui(
		"__rethink_hero_banner",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Top, true, true, 520, 250, 520, 250)
	)
	self.Widget.Title = "Rethink Editor v0.1"
	self.Widget.Name = "Hero Banner"

	local logo = Instance.new("ImageLabel")
	logo.Image = "rbxassetid://13001342589"
	logo.BackgroundTransparency = 1
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.Position = UDim2.fromScale(0.5, 0.5)
	logo.Size = UDim2.fromOffset(360, 100)
	logo.Parent = self.Widget

	local progressBarContainer = Instance.new("Frame")
	progressBarContainer.BackgroundTransparency = 1
	progressBarContainer.Position = UDim2.fromScale(0.5, 1)
	progressBarContainer.AnchorPoint = Vector2.new(0.5, 1)
	progressBarContainer.Size = UDim2.new(1, 0, 0, 25)
	progressBarContainer.Parent = self.Widget

	local progressBar = Instance.new("Frame")
	progressBar.BackgroundColor3 = Color3.fromRGB(58, 255, 75)
	progressBar.BorderSizePixel = 0
	progressBar.Size = UDim2.fromScale(0, 1)
	progressBar.Parent = progressBarContainer

	-- local spinningCircle = Instance.new("ImageLabel")
	-- spinningCircle.Size = UDim2.fromOffset(35, 35)
	-- spinningCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	-- spinningCircle.Position = UDim2.fromScale(0.5, 0.5)
	-- spinningCircle.BackgroundTransparency = 1
	-- spinningCircle.Image = "rbxassetid://14782115810"
	-- spinningCircle.Parent = self.Widget

	local statusLabelContainer = Instance.new("Frame")
	statusLabelContainer.BackgroundTransparency = 1
	statusLabelContainer.Size = UDim2.new(1, 0, 1, -25)
	statusLabelContainer.Parent = self.Widget

	local list = Instance.new("UIListLayout")
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.HorizontalAlignment = Enum.HorizontalAlignment.Left
	list.FillDirection = Enum.FillDirection.Vertical
	list.Parent = statusLabelContainer

	self.ProgressBar = progressBar
	-- self.SpinningCircle = spinningCircle
	self.StatusLabelContainer = statusLabelContainer

	return self
end

function PluginBootDisplay:CreateStatusLabel(text: string, color: Color3?)
	local statusLabel = Instance.new("TextLabel")
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Something something..."
	statusLabel.TextColor3 = if color then color else Color3.fromRGB(255, 255, 255)
	statusLabel.AnchorPoint = Vector2.new(0, 1)
	statusLabel.Position = UDim2.fromOffset(5, -3)
	statusLabel.TextSize = 11
	statusLabel.Size = UDim2.new(1, 0, 0, 25)
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Text = text
	statusLabel.AutomaticSize = Enum.AutomaticSize.Y
	statusLabel.Parent = self.StatusLabelContainer
end

function PluginBootDisplay:SetBarPercent(percentage: number)
	self.ProgressBar.Size = UDim2.fromScale(percentage, 1)
end

function PluginBootDisplay:Destroy()
	self.Widget:Destroy()
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
	local Display = PluginBootDisplay.new(PluginFramework)

	local maxStages = 0
	local stages = 0

	for _, controller: PluginFrameworkController in PluginFramework._Controllers do
		if controller.Init then
			maxStages += 1
		end

		if controller.Start then
			maxStages += 1
		end
	end

	local function WrapFunction(callback: () -> (), stage: string, controllerName: string)
		Display:CreateStatusLabel(`{stage} {controllerName}`)

		local success, errorMessage = pcall(function()
			callback()
		end)

		if success then
			stages += 1
			Display:SetBarPercent(stages / maxStages)

			return 0
		end

		Display:CreateStatusLabel(
			`Encountered an error, whilst {stage} {controllerName}:\n{errorMessage}\n\nThis could be a bug! Please file an issue on the GitHub page! If not, please restart the plugin!`,
			Color3.fromRGB(255, 96, 47)
		)

		Display.ProgressBar:Destroy()
		Display.Widget.Title = `Encountered an error!`
		Display.StatusLabelContainer.Size = Display.StatusLabelContainer.Size + UDim2.fromOffset(0, 25)

		return 1
	end

	for controllerName, controller: PluginFrameworkController in PluginFramework._Controllers do
		if not (typeof(controller.Init) == "function") then
			continue
		end

		local exitCode = WrapFunction(function()
			controller.Init(controller, Display)
		end, "initializing", controllerName)
		if exitCode == 1 then
			error("An error has occured whilst initializing! See above widget for more details!")
			break
		end

		-- controller.Init(controller)
	end

	for controllerName, controller: PluginFrameworkController in PluginFramework._Controllers do
		if not (typeof(controller.Start) == "function") then
			continue
		end

		task.spawn(function()
			-- controller.Start(controller)
			local exitCode = WrapFunction(function()
				controller.Start(controller, Display)
			end, "starting", controllerName)
			if exitCode == 1 then
				error("An error has occured whilst starting! See above widget for more details!")
				return
			end
		end)
	end

	Display:Destroy()
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
