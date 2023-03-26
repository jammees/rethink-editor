type ButtonProps = {
	Title: string,
	OnClick: () -> (),
	IconIDX: number,
}

local ICON_SET_ID = "rbxassetid://12905248305"
local ICON_SET_MAP = {
	[1] = Vector2.new(0, 0),
	[2] = Vector2.new(256, 0),
	[3] = Vector2.new(512, 0),
	[4] = Vector2.new(0, 256),
	[5] = Vector2.new(256, 256),
	[6] = Vector2.new(512, 256),
	[7] = Vector2.new(0, 512),
	[8] = Vector2.new(256, 512),
}

local TextService = game:GetService("TextService")

local library = script.Parent.Parent.Parent.Library

local ConfigSystem = require(script.Parent.Parent.Config)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local New = Fusion.New

local function createButton(props: ButtonProps)
	local textSize = TextService:GetTextSize(props.Title, 14, Enum.Font.SourceSans, Vector2.new(200, 90))

	return New("TextButton")({
		Text = "",
		Size = UDim2.new(0, textSize.X > 50 and textSize.X + 10 or 50, 0, 90),
		Name = props.Title,
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
		BorderSizePixel = 0,
		AutoButtonColor = true,

		[OnEvent("MouseButton1Click")] = props.OnClick,

		[Children] = {
			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
			}),

			Icon = New("ImageLabel")({
				Image = ICON_SET_ID,
				ImageRectSize = Vector2.new(256, 256),
				ImageRectOffset = ICON_SET_MAP[props.IconIDX],
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5),
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(40, 40),
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

return function()
	return New("Frame")({
		Name = "Toolbar",
		Size = UDim2.new(1, 0, 0, 100),
		Position = UDim2.fromOffset(0, 30),
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),

		[Children] = {
			List = New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 5),
			}),

			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
			}),

			createButton({
				Title = "Resize",
				IconIDX = 7,
				OnClick = function()
					if ConfigSystem.man_Mode:get() == 1 then
						ConfigSystem.man_Mode:set(0)
					else
						ConfigSystem.man_Mode:set(1)
					end
				end,
			}),

			createButton({
				Title = "Drag",
				IconIDX = 8,
				OnClick = function()
					if ConfigSystem.man_Mode:get() == 2 then
						ConfigSystem.man_Mode:set(0)
					else
						ConfigSystem.man_Mode:set(2)
					end
				end,
			}),
		},
	})
end
