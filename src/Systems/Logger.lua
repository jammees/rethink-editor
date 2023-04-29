local TextService = game:GetService("TextService")

local library = script.Parent.Parent.Library

local Janitor = require(library.Janitor).new()
local LabelJanitor = require(library.Janitor).new()

local widget = nil
local container = nil
local logCounter = 0

local Logger = {}

function Logger.Init(pluginPermission: Plugin)
	widget = pluginPermission:CreateDockWidgetPluginGui(
		"__rethink_logger_window",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 650, 250, 650, 250)
	)
	widget.Title = "Rethink Output Console"
	widget.Name = "Rethink Output Console"
end

function Logger.Start()
	container = Instance.new("Frame")
	container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	container.Size = UDim2.new(1, 0, 1, 0)
	container.ClipsDescendants = true

	container.Parent = widget

	local list = Instance.new("UIListLayout")
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.Parent = container

	Janitor:Add(container)
end

function Logger.Log(message: string)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = Color3.fromRGB(255, 255, 255)

	logCounter += 1

	local dimensions = TextService:GetTextSize(message, 13, Enum.Font.SourceSans, container.AbsoluteSize)

	if dimensions.Y < 25 then
		dimensions = Vector2.new(0, 25)
	end

	label.Size = UDim2.new(1, 0, 0, dimensions.Y)
	label.Parent = container

	LabelJanitor:Add(label)
end

function Logger.ToggleConsoleState(state: boolean)
	widget.Enabled = state
end

function Logger.Clear()
	LabelJanitor:Cleanup()
	Logger.Log(`Cleared {logCounter} logs successfully`)
	logCounter = 0
end

function Logger.Destroy()
	Janitor:Cleanup()
	LabelJanitor:Cleanup()
	logCounter = 0
end

return Logger
