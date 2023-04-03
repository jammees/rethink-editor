local library = script.Parent.Parent.Parent.Library
local handlers = script.Parent.Handlers

local ConfigSystem = require(script.Parent.Parent.Config)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

return function()
	return New("Frame")({
		AnchorPoint = Vector2.new(1),
		Position = UDim2.new(1, 0, 0, ConfigSystem.ui_TopbarOffset:get()),
		Size = UDim2.new(0, ConfigSystem.ui_PropertySize:get(), 1, -ConfigSystem.ui_TopbarOffset:get()),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
		Name = "Property",

		[Children] = {
			Separator = New("Frame")({
				Size = UDim2.new(1, 0, 0, 1.5),
				BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				Name = "Separator",
			}),

			Topbar = New("Frame")({
				Size = UDim2.new(1, 0, 0, 25),
				BackgroundColor3 = Color3.fromRGB(27, 27, 27),
				Name = "Topbar",

				[Children] = {
					Padding = New("UIPadding")({
						PaddingLeft = UDim.new(0, 5),
					}),

					Title = New("TextLabel")({
						Text = "Property",
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
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
				ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
				ScrollBarThickness = 6,
				TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
				BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, -30),
				Position = UDim2.fromOffset(0, 30),

				[Children] = {
					List = New("UIListLayout")({
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0, 5),
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
end
