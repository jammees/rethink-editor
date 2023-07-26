local CollectionService = game:GetService("CollectionService")

local library = script.Parent.Parent.Parent.Library

local ConfigSystem = require(script.Parent.Parent.Config).Get()

local Theme = require(script.Parent.Themes).GetTheme()

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

local scrollRef = Fusion.Value()

return function()
	local window = New("Frame")({
		AnchorPoint = Vector2.new(1),
		Position = UDim2.new(1, 0, 0, ConfigSystem.ui_TopbarOffset:get()),
		Size = UDim2.new(0, ConfigSystem.ui_PropertySize:get(), 1, -ConfigSystem.ui_TopbarOffset:get()),
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.BG1,
		Name = "Property",

		[Children] = {

			Separator = New("Frame")({
				Size = UDim2.new(1, 0, 0, 1.5),
				BackgroundColor3 = Theme.BG3,
				Name = "Separator",
			}),

			Topbar = New("Frame")({
				Size = UDim2.new(1, 0, 0, 25),
				BackgroundColor3 = Theme.BG2,
				Name = "Topbar",

				[Children] = {
					Padding = New("UIPadding")({
						PaddingLeft = UDim.new(0, 5),
					}),

					Title = New("TextLabel")({
						Text = "Property",
						BackgroundTransparency = 1,
						TextColor3 = Theme.Text1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Name = "Title",
					}),
				},
			}),

			Contents = New("ScrollingFrame")({
				Name = "Contents",
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(),
				ScrollBarImageColor3 = Theme.Text2,
				ScrollBarThickness = 6,
				TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
				BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, -30),
				Position = UDim2.fromOffset(0, 30),

				[Fusion.Ref] = scrollRef,

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
				},
			}),
		},
	})

	--CollectionService:AddTag(Fusion.peek(scrollRef), "__rethink_editor_property_scroll")
	--scrollRef:set(nil)

	local scroll: ScrollingFrame = Fusion.peek(scrollRef)

	--warn(ConfigSystem)

	--[[ ConfigSystem.ui_Handler_IsFocused:onChange(function(newValue)
		print(ConfigSystem)
		if newValue then
			scroll.ScrollingEnabled = true

			return
		end

		scroll.ScrollingEnabled = false
	end) ]]

	return window
end
