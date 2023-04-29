--[[
	toolbarButton.lua

	A toolbar handler, which creates an interactive button.
]]

type ButtonProps = {
	Title: string,
	OnClick: () -> (),
	IconIDX: string,
	Priority: number,
	Janitor: any,
}

local TextService = game:GetService("TextService")

local library = script.Parent.Parent.Parent.Parent.Parent.Library

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Attribute = Fusion.Attribute
local New = Fusion.New

return function(props: ButtonProps): TextButton
	local textSize = TextService:GetTextSize(props.Title, 14, Enum.Font.SourceSans, Vector2.new(200, 90))

	return New("TextButton")({
		Text = "",
		Size = UDim2.new(0, textSize.X > 50 and textSize.X + 10 or 50, 0, 90),
		Name = props.Title,
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
		BorderSizePixel = 0,
		AutoButtonColor = true,
		LayoutOrder = props.Priority and props.Priority or 0,

		[Attribute("ResizeInToolbar")] = true,

		[OnEvent("MouseButton1Click")] = props.OnClick,

		[Children] = {
			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
			}),

			Icon = New("ImageLabel")({
				Image = props.IconIDX,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5),
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(35, 35),
			}),

			Title = New("TextLabel")({
				Text = props.Title,
				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.fromOffset(textSize.X, textSize.Y > 25 and textSize.Y or 25),
				Position = UDim2.fromScale(0.5, 1),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}),
		},
	})
end
