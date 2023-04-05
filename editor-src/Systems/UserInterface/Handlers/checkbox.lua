type Props = {
	Title: string,
	OnStateChange: (boolean) -> (),
	InitialState: boolean,
	Priority: number,
}

local TextService = game:GetService("TextService")

local library = script.Parent.Parent.Parent.Parent.Library

local ICON_SET = require(script.Parent.Parent.ICON_SET)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

return function(props: Props)
	props.Title = props.Title or ""

	local self = setmetatable({}, {})

	self.State = props.InitialState or false

	local textSize = TextService:GetTextSize(props.Title, 14, Enum.Font.SourceSans, Vector2.new(999, 50))

	self.Object = New("TextButton")({
		Text = "",
		Size = UDim2.new(0, textSize.X + 50, 0, 20),
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
		AutoButtonColor = true,
		Name = "",
		LayoutOrder = props.Priority and props.Priority or 0,

		[Children] = {
			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 3),
				--PaddingTop = UDim.new(0, 2.5),
				--PaddingBottom = UDim.new(0, 5),
			}),

			CheckboxContainer = New("Frame")({
				Size = UDim2.fromOffset(15, 15),
				BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Name = "CheckboxContainer",

				[Children] = {
					Checkmark = New("ImageLabel")({
						Image = ICON_SET.ICON_SET_OBJ_ARROW.ICON_SET_ID,
						ImageRectSize = Vector2.new(42, 39),
						ImageRectOffset = ICON_SET.ICON_SET_OBJ_ARROW.ICON_SET_MAP.checkmark,
						BackgroundTransparency = 1,
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.new(1, -5, 1, -5),
						Name = "Checkmark",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Visible = self.State,
					}),
				},
			}),

			Title = New("TextLabel")({
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 20, 0.5, 0),
				Text = props.Title,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		},

		[Fusion.OnEvent("MouseButton1Click")] = function()
			self.State = not self.State

			self.Object.CheckboxContainer.Checkmark.Visible = self.State

			props.OnStateChange(self.State)
		end,
	})

	return self.Object
end
