type Props = {
	OnValueChange: (boolean) -> (),
	InitialValue: boolean,
	Priority: number,
	IncrementBy: number,
	Range: NumberRange,
	--IsFloatAllowed: boolean,
}

local library = script.Parent.Parent.Parent.Parent.Library

local ICON_SET = require(script.Parent.Parent.ICON_SET)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

function doesOnlyContainNums(inputString)
	local loweredInput = string.lower(inputString)

	for i = 1, #loweredInput do
		if string.match(string.sub(loweredInput, i, i), "%d") == nil and string.sub(loweredInput, i, i) ~= "." then
			return false -- found character that is not a number
		end
	end

	return true -- all are numbers
end

--[[ function isFloat(number: number): boolean
	local input = tostring(number)

	for i = 1, #input do
		if string.sub(input, i, i) == "." then
			return true
		end
	end
	return false
end ]]

return function(props: Props)
	props.OnValueChange = props.OnStateChange ~= nil and props.OnStateChange or props.OnValueChang

	local self = setmetatable({}, {})

	self.Value = props.InitialValue or 0
	self.IncrementBy = props.IncrementBy or 1
	--self.IsFloatAllowed = props.IsFloatAllowed or true
	self.Range = props.Range or NumberRange.new(-math.huge, math.huge)

	self.UpdateText = function(s)
		s.Object.Input.Text = tostring(self.Value)
	end

	self.ProcessInput = function(s, newInput: string | number)
		local input = tonumber(newInput)

		-- Clamp the value
		if self.Range.Min > input or input > self.Range.Max then
			--print("Out of bounds")
			input = math.clamp(newInput, self.Range.Min, self.Range.Max)
		end

		-- Check if the number is a float if it is and IsFloatAllowed is enabled round
		-- down the number
		--[[ if self.IsFloatAllowed and isFloat(input) then
			input = math.floor(input)
			--print("IsFloatAllowed is false and number was a float! Floored number")
		end ]]

		s.Value = input
		s:UpdateText()

		props.OnValueChange(s.Value)
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
						self:ProcessInput(newInput)
					else
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
					self:ProcessInput(self.Value + self.IncrementBy)
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
					self:ProcessInput(self.Value - self.IncrementBy)
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
