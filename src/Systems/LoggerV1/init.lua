local SEVERITY_CONFIG = {
	[1] = { "Debug", Color3.fromHex("FFFFFF") },
	[2] = { "Warning", Color3.fromHex("E28D28") },
	[3] = { "Error", Color3.fromHex("DD3F3F") },
}

local TextService = game:GetService("TextService")

local library = script.Parent.Parent.Library

local ConfigSystem = require(script.Parent.Config).Get()

local Janitor = require(library.Janitor).new()
local LabelJanitor = require(library.Janitor).new()
local Queue = require(script.Queue)

local widget = nil
local container = nil
local logCounter = 0
local loggerLabels = {}
local placeholders = {}

local Logger = {}

function Logger.Init(pluginPermission: Plugin)
	widget = pluginPermission:CreateDockWidgetPluginGui(
		"__rethink_logger_window",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 650, 250, 650, 250)
	)
	widget.Title = "Rethink Output Console"
	widget.Name = "Rethink Output Console"

	Queue.AttachProcessor(Logger._Log)
end

function Logger.Start()
	if ConfigSystem.dev_DebugMode:get() then
		widget.Enabled = true
	end

	container = Instance.new("ScrollingFrame")
	container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	container.Size = UDim2.new(1, 0, 1, 0)
	container.ClipsDescendants = true
	container.CanvasSize = UDim2.new()
	container.AutomaticCanvasSize = Enum.AutomaticSize.Y

	container.Parent = widget

	local list = Instance.new("UIListLayout")
	list.VerticalAlignment = Enum.VerticalAlignment.Top
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Name = "List"
	list.Parent = container

	Janitor:Add(container)

	Janitor:Add(widget:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		Logger._ScaleLogs()
	end))

	Janitor:Add(container:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		Logger._HideObstructedLogs()
	end))
end

function Logger.Log(moduleName: string, severity: number, log: string)
	if ConfigSystem.dev_DebugMode_Level:get() > severity then
		return
	end

	Queue.Add(moduleName, severity, log)
end

function Logger._Log(moduleName: string, severity: number, log: string)
	if not ConfigSystem.dev_DebugMode:get() then
		return
	end

	local severityConfig = SEVERITY_CONFIG[severity]

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = `{os.date("%X")} [{moduleName}] {severityConfig[1]}: {log}`
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = severityConfig[2]
	label.TextWrapped = true
	label.LayoutOrder = logCounter
	label.Parent = container

	logCounter += 1
	LabelJanitor:Add(label)
	table.insert(loggerLabels, label)

	Logger._ScaleLogs()

	local savedPos = container.CanvasPosition
	container.CanvasPosition = Vector2.new(0, 99999999999999)
	local threshold = container.CanvasPosition.Y - 50
	container.CanvasPosition = savedPos

	if container.CanvasPosition.Y >= threshold then
		container.CanvasPosition = Vector2.new(0, 99999999999999)
	end
end

function Logger._HideObstructedLogs()
	for _, label: TextLabel in loggerLabels do
		task.defer(function()
			local minPos = container.CanvasPosition.Y - 25
			local maxPos = minPos + container.AbsoluteSize.Y
			local size = label.Size.Y.Offset
			local pos = label.LayoutOrder * size

			local isTopOut = (pos - size) < minPos
			local isBottomOut = pos > maxPos

			if isTopOut or isBottomOut then
				if placeholders[label] then
					return
				end

				local placeholder = Instance.new("Frame")
				placeholder.Size = label.Size
				placeholder.BackgroundTransparency = 1
				placeholder.Name = label.Name
				placeholder.LayoutOrder = label.LayoutOrder
				placeholder.Parent = container
				placeholders[label] = placeholder

				label.Parent = nil
				label.Visible = false
			else
				local placeholder = placeholders[label]

				if placeholder then
					placeholder:Destroy()
					placeholders[label] = nil
				end

				label.Visible = true

				-- 10/10 error handling
				pcall(function()
					label.Parent = container
				end)

				Logger._ScaleLogSingleton(label)
			end
		end)
	end
end

function Logger._ScaleLogSingleton(label: TextLabel)
	local textSize =
		TextService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(label.AbsoluteSize.X, 75))

	label.Size = UDim2.new(1, 0, 0, textSize.Y)
end

function Logger._ScaleLogs()
	for _, label: TextLabel in loggerLabels do
		Logger._ScaleLogSingleton(label)
	end
end

function Logger.ToggleConsoleState(state: boolean, ignoreDevCheck: boolean)
	if not ignoreDevCheck and not ConfigSystem.dev_DebugMode:get() then
		return
	end

	widget.Enabled = state
end

function Logger.Clear()
	Queue.Clear()
	LabelJanitor:Cleanup()
	logCounter = 0
end

function Logger.Destroy()
	Queue.Clear()
	Janitor:Cleanup()
	LabelJanitor:Cleanup()
	logCounter = 0
end

return Logger
