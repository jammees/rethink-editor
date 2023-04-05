type Props = {
	Property: string,
	Priority: number,
	Handler: any,
}

local DARKENING_SELECTED_AMOUNT_THINGY = 50

local library = script.Parent.Parent.Parent.Parent.Library

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

return function(props: Props): Frame
	-- Edit the handler
	props.Handler.Size = UDim2.new(1, 0, props.Handler.Size.Y.Scale, props.Handler.Size.Y.Offset)
	--props.Handler.BackgroundTransparency = 1

	local container
	container = New("Frame")({
		Size = UDim2.new(1, 0, 0, 25),
		Name = props.Property .. " Listener",
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
		BorderSizePixel = 0,
		LayoutOrder = props.Priority and props.Priority or 0,

		--[[ [Fusion.OnEvent("MouseEnter")] = function()
			container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		end,
		[Fusion.OnEvent("MouseLeave")] = function()
			container.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
		end, ]]

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

				[Children] = { props.Handler },
			}),
		},
	})

	return container
end
