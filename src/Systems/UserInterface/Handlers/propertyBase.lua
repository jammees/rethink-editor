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

local ConfigSystem = require(script.Parent.Parent.Parent.Config).Get()

local Themes = require(script.Parent.Parent.Themes).GetTheme()

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New
local Ref = Fusion.Ref
local Value = Fusion.Value

return function(props: Props): Frame
	local titleRef = Value()

	-- Edit the handler
	props.Handler:Get().Size = UDim2.new(1, 0, props.Handler:Get().Size.Y.Scale, props.Handler:Get().Size.Y.Offset)

	return New("Frame")({
		Size = UDim2.new(1, 0, 0, 25),
		Name = props.Property,
		BackgroundColor3 = Themes.BG1,
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
				Size = UDim2.fromScale(ConfigSystem.ui_PropertyBase_TitleWidht:get(), 1),
				Name = "TitleContainer",

				[Children] = {
					Title = New("TextLabel")({
						Text = props.Property,
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						TextColor3 = Themes.Text2,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,

						[Ref] = titleRef,
					}),
				},
			}),

			HandlerContainer = New("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(ConfigSystem.ui_PropertyBase_HandlerWidht:get(), 1),
				Position = UDim2.fromScale(ConfigSystem.ui_PropertyBase_TitleWidht:get(), 0),
				Name = "HandlerContainer",

				[Children] = { props.Handler:Get() },
			}),
		},

		[Fusion.OnEvent("MouseEnter")] = function()
			Fusion.peek(titleRef).TextColor3 = Themes.Text1

			if props.Handler.InputRef then
				Fusion.peek(props.Handler.BaseRef).BackgroundColor3 = Themes.BG3
			elseif props.Handler.Handlers then
				for _, v in props.Handler.Handlers do
					Fusion.peek(v.BaseRef).BackgroundColor3 = Themes.BG3
				end
			end
		end,

		[Fusion.OnEvent("MouseLeave")] = function()
			Fusion.peek(titleRef).TextColor3 = Themes.Text2

			if props.Handler.InputRef then
				Fusion.peek(props.Handler.BaseRef).BackgroundColor3 = Themes.BG2
			elseif props.Handler.Handlers then
				for _, v in props.Handler.Handlers do
					Fusion.peek(v.BaseRef).BackgroundColor3 = Themes.BG2
				end
			end
		end,
	})
end
