local library = script.Parent.Parent.Library

local ConfigSystem = require(script.Parent.Config).Get()

local Janitor = require(library.Janitor).new()

local ToolbarUI = require(script.Toolbar)
local PropertyUI = require(script.Property)
local MenuUI = require(script.Menu)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

local Theme = require(script.Themes).GetTheme()

local UserInterface = {}
UserInterface.UI = nil
UserInterface.Handlers = script.Handlers

function UserInterface.Start(window: DockWidgetPluginGui)
	local property = PropertyUI()

	UserInterface.UI = New("Frame")({
		Parent = window,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.WorkspaceBG,
		ZIndex = -999999999,
		Name = "Container",

		[Children] = {
			Workspace = New("Frame")({
				Size = UDim2.new(1, -ConfigSystem.ui_PropertySize:get(), 1, -ConfigSystem.ui_TopbarOffset:get()),
				Position = UDim2.fromOffset(0, 130),
				BackgroundTransparency = 1,
				Name = "Workspace",
			}),

			Detector = New("TextButton")({
				Size = UDim2.new(1, -ConfigSystem.ui_PropertySize:get(), 1, -ConfigSystem.ui_TopbarOffset:get()),
				Position = UDim2.fromOffset(0, 130),
				BackgroundTransparency = 1,
				TextTransparency = 1,
				AutoButtonColor = false,
				Name = "Detector",
			}),

			Editor = New("Frame")({
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Name = "Editor",

				[Children] = {
					Menu = MenuUI(),
					Toolbar = ToolbarUI(),
					Property = property,
				},
			}),
		},
	})

	Janitor:Add(UserInterface.UI)
end

function UserInterface.Destroy()
	Janitor:Cleanup()
end

return UserInterface
