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

local Theme = require(script.Parent.Parent.Parent.Themes).GetTheme()

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Attribute = Fusion.Attribute
local New = Fusion.New

return function(props: ButtonProps): TextButton
	local textSize = TextService:GetTextSize(props.Title, 14, Enum.Font.SourceSans, Vector2.new(200, 90))

	return New("TextButton")({
		Text = props.Title,
		Size = UDim2.new(0, textSize.X > 50 and textSize.X + 10 or 50, 1, -3),
		Name = props.Title,
		BackgroundColor3 = Theme.BG1,
		BorderSizePixel = 0,
		AutoButtonColor = true,
		TextColor3 = Theme.Text1,
		LayoutOrder = props.Priority and props.Priority or 0,

		[OnEvent("MouseButton1Click")] = props.OnClick,
	})
end
