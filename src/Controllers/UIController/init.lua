local SIZE = Vector2.new(1200, 700)
local MIN_SIZE = Vector2.new(900, 400)
local INIT_STATE = Enum.InitialDockState.Float
local WIDGET_INFO = DockWidgetPluginGuiInfo.new(INIT_STATE, false, false, SIZE.X, SIZE.Y, MIN_SIZE.X, MIN_SIZE.Y)

local Types = require(script.Parent.Utility.Types)
local Signal = require(script.Parent.Parent.Vendors.GoodSignal)
local IrisModule = require(script.Parent.Parent.Vendors["Iris-plugin"])
local Janitor = require(script.Parent.Parent.Library.Janitor)
local PluginFramework = require(script.Parent.Parent.Library.PluginFramework)
local IrisTypes = require(script.Parent.Parent.Vendors["Iris-plugin"].Types)

local function GenerateInstances(parent: DockWidgetPluginGui, Iris: IrisTypes.Iris)
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

	self.Widget = self.Framework._Plugin:CreateDockWidgetPluginGui("__rethink_editor_widget", WIDGET_INFO)
	self.Widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.Widget.Enabled = false

	self.Widget:BindToClose(function()
		require(script.Utility).ExitPromtActive:set(true)
	end)

	if self.Iris then
		self.Iris.Internal._started = false
	end
	self.Iris = IrisModule.Init(self.Widget)
	self.Iris.Disabled = true

	self.WidgetSize = self.Iris.State(self.Widget.AbsoluteSize)

	UIController.Widget:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self.WidgetSize:set(self.Widget.AbsoluteSize)
	end)

	self.COPromtActive = self.Iris.State(false)
	self.SettingsWindowActive = self.Iris.State(false)

	self.ClickDetector, self.Workspace = GenerateInstances(self.Widget, self.Iris)

	self.WidgetToggled = Signal.new()
	self.Widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		self.WidgetToggled:Fire(self.Widget.Enabled)
	end)

	self.Renderers = {}
	for _, renderer in script.Renderers:GetChildren() do
		local Renderer = require(renderer)
		self.Renderers[Renderer.Priority] = Renderer
	end

	self._Janitor:Add(self.Widget)
	self._Janitor:Add(self.ClickDetector)
	self._Janitor:Add(self.Workspace)
	self._Janitor:Add(self.WidgetToggled, "DisconnectAll")
	self._Janitor:Add(function()
		self.Iris.Disabled = true
		table.clear(self.Iris.Internal._connectedFunctions)
	end)
end

function UIController:_RenderCOPromt()
	if not self.COPromtActive.value then
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
	}, { position = positionState, size = sizeState, isOpened = self.COPromtActive })

	self.Iris.InputText({ "Name" }, { text = nameState })
	self.Iris.ComboArray({ "Class" }, { index = classState }, { "Frame", "TextLabel", "ImageLabel" })
	self.Iris.ComboArray({ "Kind" }, { index = kindState }, { "UIbase", "Rigidbody" })

	self.Iris.PushConfig({ TextColor = Color3.fromRGB(117, 117, 117) })
	self.Iris.Text({ "This can be later configured!" })
	self.Iris.PopConfig()

	self.Iris.SameLine()
	if self.Iris.Button({ "Cancel" }).clicked() then
		self.COPromtActive:set(false)
	end
	if self.Iris.Button({ "Done" }).clicked() then
		self.COPromtActive:set(false)

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
		self.SettingsWindowActive:set(not self.SettingsWindowActive.value)
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

	self.Iris.SameLine()
	if self.Iris.Button({ "Restart" }).clicked() then
		self.Framework.Stop()
		self.Framework.Start()

		self.Widget.Enabled = true
	end
	self.Iris.Text({
		"Warning: Resetting plugin might cause issues with rendering!",
		[self.Iris.Args.Text.Color] = Color3.fromRGB(233, 80, 80),
		[self.Iris.Args.Text.Wrapped] = true,
	})
	self.Iris.End()

	if self.Iris.Button({ "Fetch config data" }).clicked() then
		print(self.ConfigController.Config)
	end

	self.Iris.Separator()

	for settingName, valueClass in self.ConfigController.Config do
		self.Iris.Table({
			3,
			[self.Iris.Args.Table.RowBg] = false,
			[self.Iris.Args.Table.BordersInner] = false,
			[self.Iris.Args.Table.BordersOuter] = false,
		})
		self.Iris.Text(`{settingName}`)
		self.Iris.NextColumn()

		self.Iris.PushConfig({ ContentWidth = UDim.new(1, 0) })
		if typeof(valueClass.value) == "string" then
			self.Iris.InputText({ "" }, { text = valueClass })
		elseif typeof(valueClass.value) == "number" then
			self.Iris.InputNum({ "" }, { number = valueClass })
		elseif typeof(valueClass.value) == "boolean" then
			self.Iris.Checkbox({ "" }, { isChecked = valueClass })
		elseif typeof(valueClass.value) == "Vector2" then
			self.Iris.DragVector2({ "" }, { number = valueClass })
		else
			self.Iris.Text({ "corrupted", [self.Iris.Args.Text.Color] = Color3.fromRGB(218, 48, 48) })
		end
		self.Iris.PopConfig()

		self.Iris.NextColumn()

		local windowOpen = self.Iris.State(false)
		local selectedType = self.Iris.State("boolean")
		local value = self.Iris.State("")
		local supportedValues = { "boolean", "number", "string", "none" }

		if self.Iris.Button({ "Set value" }).clicked() then
			windowOpen:set(true)
		end

		self.Iris.Window({ `Set value for {settingName}` }, { isOpened = windowOpen })

		self.Iris.Text({
			"Mostly a debug menu to more easily edit values that have been corrupted or changed over-time. USE ONLY IF VALUE IS CORRUPTED!",
			[self.Iris.Args.Text.Wrapped] = true,
		})

		self.Iris.SameLine()

		if self.Iris.Button({ "Cancel" }).clicked() then
			windowOpen:set(false)
		end

		if self.Iris.Button({ "Apply" }).clicked() then
			windowOpen:set(false)

			local kind = selectedType.value
			local pValue = value.value
			local convertedValue

			if kind == "boolean" then
				convertedValue = if string.lower(pValue) == "true" then true else false
			elseif kind == "number" then
				convertedValue = tonumber(pValue)
			elseif kind == "string" then
				convertedValue = pValue
			elseif kind == "none" then
				convertedValue = {}
			end

			valueClass:set(convertedValue)
			self.ConfigController:Save()
		end

		self.Iris.End()

		self.Iris.Separator()

		self.Iris.ComboArray({ "Value type" }, { index = selectedType }, supportedValues)
		self.Iris.InputText({ "Value" }, { text = value })

		self.Iris.End()

		self.Iris.End()
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
	self.Iris.Disabled = false

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

		for _, module in self.Renderers do
			module.Render(self.Iris)
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
