type Props = {
	OnValueChange: (boolean) -> (),
	InitialValue: boolean,
	Priority: number,
	IncrementBy: number,
}

local library = script.Parent.Parent.Parent.Parent.Library

local ICON_SET = require(script.Parent.Parent.ICON_SET)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

function doesOnlyContainNums(inputString)
	local loweredInput = string.lower(inputString)

	for i = 1, #loweredInput do
		if string.match(string.sub(loweredInput, i, i), "%d") == nil then
			return false -- found character that is not a number
		end
	end

	return true -- all are numbers
end

return function(props: Props)
	local self = setmetatable({}, {})

	self.Value = props.InitialValue or 0
	self.IncrementBy = props.IncrementBy or 1

	self.UpdateText = function(s)
		s.Object.Input.Text = tostring(self.Value)
	end

	self.Object = New("Frame")({
		Size = UDim2.new(0, 100, 0, 20),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		Name = "NumberField",
		LayoutOrder = props.Priority and props.Priority or 0,

		[Children] = {
			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 3),
			}),

			Input = New("TextBox")({
				Name = "Input",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -25, 1, 0),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Left,

				[Fusion.OnEvent("FocusLost")] = function()
					local newInput = self.Object.Input.Text
					local onlyNums = doesOnlyContainNums(string.lower(newInput))

					if onlyNums then
						self.Value = tonumber(newInput)
						props.OnValueChange(self.Value)
						self:UpdateText()
					else
						props.OnValueChange(self.Value)
						self:UpdateText()
					end
				end,
			}),

			IncrementUp = New("TextButton")({
				Size = UDim2.new(0, 25, 0.5, -0.5),
				Position = UDim2.new(1, 0, 0, 0),
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				BorderSizePixel = 0,
				AutoButtonColor = true,
				Text = "",

				[Fusion.OnEvent("MouseButton1Click")] = function()
					self.Value += self.IncrementBy
					self:UpdateText()
					props.OnValueChange(self.Value)
				end,

				[Children] = {
					Icon = New("ImageLabel")({
						Image = ICON_SET.ICON_SET_ARROW.ICON_SET_ID,
						ImageRectOffset = ICON_SET.ICON_SET_ARROW.ICON_SET_MAP.up,
						ImageRectSize = ICON_SET.ICON_SET_ARROW.ICON_SET_SIZE,
						BackgroundTransparency = 1,
						Size = UDim2.fromOffset(20, 20),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
					}),
				},
			}),

			IncrementDown = New("TextButton")({
				Size = UDim2.new(0, 25, 0.5, -0.5),
				Position = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(1, 1),
				BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				BorderSizePixel = 0,
				AutoButtonColor = true,
				Text = "",

				[Fusion.OnEvent("MouseButton1Click")] = function()
					self.Value -= self.IncrementBy
					self:UpdateText()
					props.OnValueChange(self.Value)
				end,

				[Children] = {
					Icon = New("ImageLabel")({
						Image = ICON_SET.ICON_SET_ARROW.ICON_SET_ID,
						ImageRectOffset = ICON_SET.ICON_SET_ARROW.ICON_SET_MAP.down,
						ImageRectSize = ICON_SET.ICON_SET_ARROW.ICON_SET_SIZE,
						BackgroundTransparency = 1,
						Size = UDim2.fromOffset(20, 20),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
					}),
				},
			}),
		},
	})

	self:UpdateText()

	return self.Object
end
