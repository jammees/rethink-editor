local CollectionService = game:GetService("CollectionService")

local library = script.Parent.Parent.Parent.Library

local ConfigSystem = require(script.Parent.Parent.Config).Get()

local MenuButton = require(script.Parent.Handlers.Menu.MenuButton)
local Theme = require(script.Parent.Themes).GetTheme()

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

return function()
	return New("Frame")({
		Name = "Menu",
		Size = UDim2.new(1, 0, 0, ConfigSystem.ui_MenuSize:get()),
		BackgroundColor3 = Theme.BG2,

		[Children] = {
			Settings = MenuButton({
				Title = "Settings",
				OnClick = function()
					local widget = CollectionService:GetTagged("__rethink_config_widget")[1]
					widget.Enabled = not widget.Enabled
				end,
			}),

			Import = MenuButton({
				Title = "Import",
				OnClick = function() end,
			}),

			List = New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 5),
			}),
		},
	})
end
