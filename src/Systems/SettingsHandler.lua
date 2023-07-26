local CollectionService = game:GetService("CollectionService")

local library = script.Parent.Parent.Library

local ConfigSystem = require(script.Parent.Config)
local PropertyHandlerSystem = require(script.Parent.PropertyHandler)

local PropertyBase = require(script.Parent.UserInterface.Handlers.PropertyBase)
local PropertyCategory = require(script.Parent.UserInterface.Handlers.PropertyCategory)
local Label = require(script.Parent.UserInterface.Handlers.Base.Label)

local Janitor = require(library.Janitor).new()
local Theme = require(script.Parent.UserInterface.Themes).GetTheme()

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

local widget = nil

local SettingsHandler = {}
SettingsHandler.Widget = widget

function SettingsHandler.Init(pluginPermission: Plugin)
	widget = pluginPermission:CreateDockWidgetPluginGui(
		"__rethink_settings_window",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 650, 250, 650, 250)
	)
	widget.Title = "Settings"
	widget.Name = "Settings"

	CollectionService:AddTag(widget, "__rethink_config_widget")
end

function SettingsHandler.Start()
	local container = New("ScrollingFrame")({
		Name = "Contents",
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarImageColor3 = Theme.Text2,
		ScrollBarThickness = 6,
		TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		BackgroundColor3 = Theme.BG1,
		Size = UDim2.new(1, 0, 1, -30),
		Position = UDim2.fromOffset(0, 30),
		Parent = widget,

		[Children] = {
			List = New("UIListLayout")({
				FillDirection = Enum.FillDirection.Vertical,
				--Padding = UDim.new(0, 5),
			}),

			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 11),
				PaddingBottom = UDim.new(0, 5),
			}),

			-- Add some infos n` stuffs idk
			Label.new({ InitialValue = "Settings" }):Get(),
			Label.new({ InitialValue = "This is where the editor can be more configured to your liking!" }):Get(),
			Label.new({
				InitialValue = "Disclaimer: The plugin must be full reset to apply all of the changes, notably when changing themes!",
			}):Get(),
			Label.new({ InitialValue = "" }):Get(),
		},
	})

	Janitor:Add(container)

	local Categories = {}

	for name, valueClass in ConfigSystem.Get() do
		local kind = string.split(name, "_")[1]

		if not Categories[kind] then
			local categoryClass = PropertyCategory.new({ Name = kind, Janitor = Janitor })
			categoryClass:GetUI().Parent = container

			Categories[kind] = categoryClass
		end

		local handler = PropertyHandlerSystem.GetHandler(typeof(valueClass:get()))

		local newBase = PropertyBase({
			Handler = handler.new({
				-- Props here
				Priority = 1,
				Janitor = Janitor,
				InitialValue = valueClass:get(),
				OnValueChange = function(newValue)
					valueClass:set(newValue)
					ConfigSystem.Save()
				end,
			}),

			Janitor = Janitor,
			Property = name,
		})

		Categories[kind]:Add(newBase)
	end
end

function SettingsHandler.Destroy()
	Janitor:Cleanup()
end

return SettingsHandler
