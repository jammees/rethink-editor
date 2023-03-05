local library = script.Parent.Parent.Library

local Janitor = require(library.Janitor).new()

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

local UserInterface = {}
UserInterface.UI = nil

function UserInterface.Start(window: DockWidgetPluginGui)
	UserInterface.UI = New("Frame")({
		Parent = window,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(35, 68, 139),
		Name = "Container",

		[Children] = {
			Workspace = New("Frame")({
				Size = UDim2.new(1, 0, 1, -130),
				Position = UDim2.fromOffset(0, 130),
				BackgroundTransparency = 1,
				Name = "Workspace",
			}),

			Detector = New("TextButton")({
				Size = UDim2.new(1, 0, 1, -130),
				Position = UDim2.fromOffset(0, 130),
				BackgroundTransparency = 1,
				TextTransparency = 1,
				AutoButtonColor = false,
				ZIndex = 2,
				Name = "Detector",
			}),

			Editor = New("Frame")({
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Name = "Editor",

				[Children] = {
					Menu = New("Frame")({
						Name = "Menu",
						Size = UDim2.new(1, 0, 0, 30),
						BackgroundColor3 = Color3.fromRGB(22, 22, 22),
					}),

					Toolbar = New("Frame")({
						Name = "Toolbar",
						Size = UDim2.new(1, 0, 0, 100),
						Position = UDim2.fromOffset(0, 30),
						BackgroundColor3 = Color3.fromRGB(32, 32, 32),

						-- TODO: Padding, List and dynamically create buttons
					}),
				},
			}),
		},
	})

	Janitor:Add(UserInterface.UI)

	window.Enabled = true
end

function UserInterface.Destroy()
	Janitor:Cleanup()
end

return UserInterface
