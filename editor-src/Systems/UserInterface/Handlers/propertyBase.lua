--[[
	propertyBase.lua

	An utility handler for property, which accepts another handler for input.
]]

type Props = {
	Property: string,
	Priority: number,
	Handler: any,
	Janitor: any,
}

local library = script.Parent.Parent.Parent.Parent.Library

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

return function(props: Props): Frame
	-- Edit the handler
	props.Handler:Get().Size = UDim2.new(1, 0, props.Handler:Get().Size.Y.Scale, props.Handler:Get().Size.Y.Offset)

	return New("Frame")({
		Size = UDim2.new(1, 0, 0, 25),
		Name = props.Property .. " Listener",
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
		BorderSizePixel = 0,
		LayoutOrder = props.Priority and props.Priority or 0,

		[Children] = {
			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 2.5),
				PaddingBottom = UDim.new(0, 5),
			}),

			TitleContainer = New("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.5, 1),
				Name = "TitleContainer",

				[Children] = {
					Title = New("TextLabel")({
						Text = props.Property,
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
					}),
				},
			}),

			HandlerContainer = New("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.5, 1),
				Position = UDim2.fromScale(0.5, 0),
				Name = "HandlerContainer",

				[Children] = { props.Handler:Get() },
			}),
		},
	})
end
