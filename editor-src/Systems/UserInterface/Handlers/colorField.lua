-- Oh no

type Props = {
	OnValueChange: (boolean) -> (),
	InitialValue: boolean,
	Priority: number,
}

local USE_COLOR = false
local DEF_COLOR = Color3.fromRGB(22, 22, 22)

local library = script.Parent.Parent.Parent.Parent.Library

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
	props.OnValueChange = props.OnStateChange ~= nil and props.OnStateChange or props.OnValueChang

	local self = setmetatable({}, {})

	self.ValueR = props.InitialValue.R or 255
	self.ValueG = props.InitialValue.G or 255
	self.ValueB = props.InitialValue.B or 255

	-- Convert the unit to 255
	if props.InitialValue then
		self.ValueR *= 255
		self.ValueG *= 255
		self.ValueB *= 255
	end

	self.UpdateText = function(s)
		s.Object.InputR.Text = tostring(math.floor(self.ValueR))
		s.Object.InputG.Text = tostring(math.floor(self.ValueG))
		s.Object.InputB.Text = tostring(math.floor(self.ValueB))
	end

	self.Object = New("Frame")({
		Size = UDim2.new(0, 100, 0, 20),
		BackgroundTransparency = 1,
		Name = "NumberField",
		LayoutOrder = props.Priority and props.Priority or 0,

		[Children] = {
			--[[ Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 3),
			}), ]]

			List = New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2.5),
			}),

			InputR = New("TextBox")({
				Name = "InputR",
				Size = UDim2.new(0.33, 0, 1, 0),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = USE_COLOR and Color3.fromHex("DD3F3F") or DEF_COLOR,
				LayoutOrder = 1,

				[Fusion.OnEvent("FocusLost")] = function()
					local newInput = tonumber(math.floor(self.Object.InputR.Text))
					local onlyNums = doesOnlyContainNums(string.lower(tostring(newInput)))
					newInput = math.clamp(newInput, 0, 255)

					if onlyNums and tostring(newInput):len() <= 3 then
						self.ValueR = newInput

						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					else
						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					end
				end,
			}),

			InputG = New("TextBox")({
				Name = "InputG",
				Size = UDim2.new(0.33, 0, 1, 0),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = USE_COLOR and Color3.fromHex("43C538") or DEF_COLOR,
				LayoutOrder = 2,

				[Fusion.OnEvent("FocusLost")] = function()
					local newInput = tonumber(math.floor(self.Object.InputG.Text))
					local onlyNums = doesOnlyContainNums(string.lower(tostring(newInput)))
					newInput = math.clamp(newInput, 0, 255)

					if onlyNums and tostring(newInput):len() <= 3 then
						self.ValueG = newInput

						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					else
						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					end
				end,
			}),

			InputB = New("TextBox")({
				Name = "InputB",
				Size = UDim2.new(0.33, 0, 1, 0),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = USE_COLOR and Color3.fromHex("385FC5") or DEF_COLOR,
				LayoutOrder = 3,

				[Fusion.OnEvent("FocusLost")] = function()
					local newInput = tonumber(math.floor(self.Object.InputB.Text))
					local onlyNums = doesOnlyContainNums(string.lower(tostring(newInput)))
					newInput = math.clamp(newInput, 0, 255)

					if onlyNums and tostring(newInput):len() <= 3 then
						self.ValueB = newInput

						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					else
						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					end
				end,
			}),
		},
	})

	self:UpdateText()

	return self.Object
end
