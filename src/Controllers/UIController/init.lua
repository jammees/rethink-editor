local SIZE_X = 1200
local SIZE_Y = 700
local INIT_STATE = Enum.InitialDockState.Float

local Types = require(script.Parent.Utility.Types)
local Signal = require(script.Parent.Parent.Vendors.GoodSignal)
local IrisModule = require(script.Parent.Parent.Vendors["Iris-plugin"])
local Janitor = require(script.Parent.Parent.Library.Janitor)
local PluginFramework = require(script.Parent.Parent.Library.PluginFramework)

local COPromtActive = IrisModule.State(false)
local SettingsWindowActive = IrisModule.State(false)

local renderes = script.Renderers:GetChildren()

local function GenerateInstances(parent: DockWidgetPluginGui, Iris: typeof(IrisModule))
	local ClickDetector = Instance.new("TextButton")
	ClickDetector.Size = UDim2.fromScale(1, 1)
	ClickDetector.AutoButtonColor = false
	ClickDetector.BackgroundColor3 = Iris.TemplateConfig.colorDark.TitleBgActiveColor
	ClickDetector.Name = "ClickDetector"
	ClickDetector.ZIndex = -1
	ClickDetector.Text = ""
	ClickDetector.Parent = parent

	local Workspace = Instance.new("Frame")
	Workspace.Size = UDim2.fromScale(1, 1)
	Workspace.BackgroundTransparency = 1
	Workspace.Name = "Workspace"
	Workspace.ZIndex = 0
	Workspace.Parent = parent

	return ClickDetector, Workspace
end

local UIController = PluginFramework.CreateController("UIController")

function UIController:Init()
	self._Janitor = Janitor.new()

	self.Widget = self.Framework._Plugin:CreateDockWidgetPluginGui(
		"__rethink_editor_widget",
		DockWidgetPluginGuiInfo.new(INIT_STATE, false, false, SIZE_X, SIZE_Y, SIZE_X, SIZE_Y)
	)
	self.Widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Even if enabling the widget while it's initiating is weird
	-- it's there to prevent Iris from crying about the parent not
	-- being big enough (It is big enough)
	self.Widget.Enabled = true

	self.Iris = IrisModule.Init(self.Widget)

	self.Widget.Enabled = false

	self.ClickDetector, self.Workspace = GenerateInstances(self.Widget, self.Iris)

	self.WidgetToggled = Signal.new()
	self.Widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		self.WidgetToggled:Fire(self.Widget.Enabled)
	end)
end

function UIController:_RenderCOPromt()
	if not COPromtActive.value then
		return
	end

	local ObjectController = self.Framework.GetController("ObjectController")

	local nameState = self.Iris.WeakState("")
	local kindState = self.Iris.WeakState("UIbase")
	local classState = self.Iris.WeakState("Frame")
	local sizeState = self.Iris.State(Vector2.new(350, 165))
	local positionState = self.Iris.State(
		Vector2.new(
			self.ClickDetector.AbsoluteSize.X / 2 - sizeState.value.X / 2,
			self.ClickDetector.AbsoluteSize.Y / 2 - sizeState.value.Y / 2
		)
	)

	if
		Vector2.new(
			self.ClickDetector.AbsoluteSize.X / 2 - sizeState.value.X / 2,
			self.ClickDetector.AbsoluteSize.Y / 2 - sizeState.value.Y / 2
		) ~= positionState.value
	then
		positionState:set(
			Vector2.new(
				self.ClickDetector.AbsoluteSize.X / 2 - sizeState.value.X / 2,
				self.ClickDetector.AbsoluteSize.Y / 2 - sizeState.value.Y / 2
			)
		)
	end

	self.Iris.Window({
		"Create new object",
		[self.Iris.Args.Window.NoResize] = true,
		[self.Iris.Args.Window.NoMove] = true,
		[self.Iris.Args.Window.NoCollapse] = true,
		[self.Iris.Args.Window.NoScrollbar] = true,
	}, { position = positionState, size = sizeState, isOpened = COPromtActive })

	self.Iris.InputText({ "Name" }, { text = nameState })
	self.Iris.ComboArray({ "Class" }, { index = classState }, { "Frame", "TextLabel", "ImageLabel" })
	self.Iris.ComboArray({ "Kind" }, { index = kindState }, { "UIbase", "Rigidbody" })

	self.Iris.PushConfig({ TextColor = Color3.fromRGB(117, 117, 117) })
	self.Iris.Text({ "This can be later configured!" })
	self.Iris.PopConfig()

	self.Iris.SameLine()
	if self.Iris.Button({ "Cancel" }).clicked() then
		COPromtActive:set(false)
	end
	if self.Iris.Button({ "Done" }).clicked() then
		COPromtActive:set(false)

		task.spawn(function()
			ObjectController:CreateObject(classState.value, kindState.value, { Name = nameState.value })
		end)
	end
	self.Iris.End()

	self.Iris.End()
end

function UIController:_RenderExplorer()
	local sizeState = self.Iris.State(Vector2.new(0, 0))
	local positionState = self.Iris.State(Vector2.new(0, self.ConfigController.Config.MenuBarSizeY.value))
	local selectedState = self.Iris.State(1)

	if self.ClickDetector.AbsoluteSize.Y ~= sizeState.value.Y then
		sizeState:set(
			Vector2.new(
				self.ConfigController.Config.ExplorerSizeX.value,
				self.ClickDetector.AbsoluteSize.Y - self.ConfigController.Config.MenuBarSizeY.value
			)
		)
	end

	self.ConfigController.Config.MenuBarSizeY:onChange(function(newValue)
		positionState:set(Vector2.new(0, newValue))
	end)

	self.Iris.Window({
		"Scene Explorer",
		[self.Iris.Args.Window.NoClose] = true,
		[self.Iris.Args.Window.NoResize] = true,
		[self.Iris.Args.Window.NoMove] = true,
		[self.Iris.Args.Window.NoCollapse] = true,
	}, { position = positionState, size = sizeState })

	for index, objectData: Types.ObjectData in self.ObjectController.Objects do
		local selectable = self.Iris.Selectable({ objectData.Object.Name, index }, { index = selectedState })

		if selectable.selected() then
			self.SelectionController.SelectedObject = objectData
			self.SelectionController.NewSelection:Fire()
			self.SelectionController.Triggered:Fire()
		end

		-- if selectable.unselected() then
		-- 	if selectedState.value == index then
		-- 		selectedState:set(index)
		-- 	end
		-- end
	end

	self.Iris.End()
end

function UIController:_RenderToolbarAndMenu()
	local sizeState = self.Iris.State(Vector2.new())

	if self.ClickDetector.AbsoluteSize.X ~= sizeState.value.X then
		sizeState:set(Vector2.new(self.ClickDetector.AbsoluteSize.X, self.ConfigController.Config.MenuBarSizeY.value))
	end

	self.ConfigController.Config.MenuBarSizeY:onChange(function()
		sizeState:set(Vector2.new(self.ClickDetector.AbsoluteSize.X, self.ConfigController.Config.MenuBarSizeY.value))
	end)

	self.Iris.Window({
		"",
		[self.Iris.Args.Window.NoClose] = true,
		[self.Iris.Args.Window.NoResize] = true,
		[self.Iris.Args.Window.NoMove] = true,
		[self.Iris.Args.Window.NoCollapse] = true,
		[self.Iris.Args.Window.NoTitleBar] = true,
	}, { position = Vector2.new(0, 0), size = sizeState })

	self.Iris.SameLine()

	if self.Iris.Button({ "Settings" }).clicked() then
		SettingsWindowActive:set(not SettingsWindowActive.value)
	end

	self.Iris.End()

	self.Iris.Separator()

	self.Iris.End()
end

function UIController:_RenderSettings()
	-- if not SettingsWindowActive.value then
	-- 	return
	-- end

	-- self.Iris.Window({ "Settings" }, { isOpened = SettingsWindowActive })
	self.Iris.Window({ "Settings" })

	if self.Iris.Button({ "Apply" }).clicked() then
		self.Iris.UpdateGlobalConfig(self.Iris.TemplateConfig[self.ConfigController.Config.UITheme.value])
		self.Iris.UpdateGlobalConfig({ WindowBgTransparency = 0 })
	end

	for settingName, valueClass in self.ConfigController.Config do
		if typeof(valueClass.value) == "string" then
			self.Iris.InputText({ settingName }, { text = valueClass })
		elseif typeof(valueClass.value) == "number" then
			self.Iris.InputNum({ settingName }, { number = valueClass })
		elseif typeof(valueClass.value) == "boolean" then
			self.Iris.Checkbox({ settingName }, { isChecked = valueClass })
		end
	end

	self.Iris.End()
end

function UIController:_RenderProperty()
	if not self.SelectionController.SelectedObject then
		return
	end

	self.Iris.Window({
		"Property",
		[self.Iris.Args.Window.NoClose] = true,
		[self.Iris.Args.Window.NoResize] = true,
		[self.Iris.Args.Window.NoMove] = true,
		[self.Iris.Args.Window.NoCollapse] = true,
	})

	for _, data in self.ObjectController:GetPropertiesOf(self.SelectionController.SelectedObject.Class) do
		self.Iris.Text({ `{data.Name} = {data.ValueType.Name}` })
	end

	self.Iris.End()
end

function UIController:COPromt()
	-- COPromtActive:set(true)
	require(script.Utility).CreateNewObjectActive:set(true)
end

function UIController:Start()
	self.ObjectController = self.Framework.GetController("ObjectController")
	self.ConfigController = self.Framework.GetController("ConfigController")
	self.SelectionController = self.Framework.GetController("SelectionController")

	self.Widget.Title = self.ConfigController.Config.WidgetTitle.value
	self.ConfigController.Config.WidgetTitle:onChange(function(newValue)
		self.Widget.Title = newValue
	end)

	local success = pcall(function()
		self.Iris.UpdateGlobalConfig(self.Iris.TemplateConfig[self.ConfigController.Config.UITheme.value])
	end)

	if not success then
		self.Iris.UpdateGlobalConfig(self.Iris.TemplateConfig.colorDark)
		self.ConfigController.Config.UITheme:set("colorDark")
	end

	self.Iris.UpdateGlobalConfig({ WindowBgTransparency = 0 })

	self.Iris:Connect(function()
		-- self:_RenderCOPromt()
		-- self:_RenderExplorer()
		-- self:_RenderToolbarAndMenu()
		-- self:_RenderProperty()

		for _, module in renderes do
			require(module)()
		end

		self:_RenderSettings()

		if self.ConfigController.Config.DebugMode.value then
			self.Iris.ShowDemoWindow()
		end
	end)
end

function UIController:Stop()
	self._Janitor:Destroy()
end

return UIController
