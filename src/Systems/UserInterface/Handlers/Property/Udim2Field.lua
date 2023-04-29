--[[
	colorField.lua

	A property handler, which accepts three numbers for R, G and B.
]]

type Props = {
	OnValueChange: (boolean) -> (),
	InitialValue: UDim2,
	Priority: number,
	Janitor: any,
	Object: GuiBase2d,
	Property: string,
}

local USE_COLOR = false
local DEF_COLOR = Color3.fromRGB(22, 22, 22)

local library = script.Parent.Parent.Parent.Parent.Parent.Library

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

return function(props: Props)
	props.OnValueChange = props.OnStateChange ~= nil and props.OnStateChange or props.OnValueChang

	local self = setmetatable({}, {})

	self.XScale = props.InitialValue.X.Scale
	self.XOffset = props.InitialValue.X.Offset
	self.YScale = props.InitialValue.Y.Scale
	self.YOffset = props.InitialValue.Y.Offset

	self.UpdateText = function()
		self.Object.XScale.Text = tostring(self.XScale)
		self.Object.XOffset.Text = tostring(self.XOffset)
		self.Object.YScale.Text = tostring(self.YScale)
		self.Object.YOffset.Text = tostring(self.YOffset)
	end

	self.ValidateValue = function(_, input: number, fieldName: string)
		local newInput = tonumber(input)
		local onlyNums = doesOnlyContainNums(string.lower(tostring(newInput)))

		if onlyNums then
			self[fieldName] = newInput

			props.OnValueChange(UDim2.new(self.XScale, self.XOffset, self.YScale, self.YOffset))
			self:UpdateText()
		else
			props.OnValueChange(UDim2.new(self.XScale, self.XOffset, self.YScale, self.YOffset))
			self:UpdateText()
		end
	end

	self.Object = New("Frame")({
		Size = UDim2.new(0, 100, 0, 20),
		BackgroundTransparency = 1,
		Name = "Udim2Field",
		LayoutOrder = props.Priority and props.Priority or 0,

		[Children] = {
			List = New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2.5),
			}),

			XScale = New("TextBox")({
				Name = "XScale",
				Size = UDim2.new(0.25, 0, 1, 0),
				TextColor3 = Color3.fromHex("F15959"),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = USE_COLOR and Color3.fromHex("DD3F3F") or DEF_COLOR,
				LayoutOrder = 1,

				[Fusion.OnEvent("FocusLost")] = function()
					self:ValidateValue(self.Object.XScale.Text, "XScale")
				end,
			}),

			XOffset = New("TextBox")({
				Name = "XOffset",
				Size = UDim2.new(0.25, 0, 1, 0),
				TextColor3 = Color3.fromHex("F15959"),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = USE_COLOR and Color3.fromHex("43C538") or DEF_COLOR,
				LayoutOrder = 2,

				[Fusion.OnEvent("FocusLost")] = function()
					self:ValidateValue(self.Object.XOffset.Text, "XOffset")
				end,
			}),

			YScale = New("TextBox")({
				Name = "YScale",
				Size = UDim2.new(0.25, 0, 1, 0),
				TextColor3 = Color3.fromHex("6CE362"),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = USE_COLOR and Color3.fromHex("385FC5") or DEF_COLOR,
				LayoutOrder = 3,

				[Fusion.OnEvent("FocusLost")] = function()
					self:ValidateValue(self.Object.YScale.Text, "YScale")
				end,
			}),

			YOffset = New("TextBox")({
				Name = "YOffset",
				Size = UDim2.new(0.25, 0, 1, 0),
				TextColor3 = Color3.fromHex("6CE362"),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = USE_COLOR and Color3.fromHex("385FC5") or DEF_COLOR,
				LayoutOrder = 3,

				[Fusion.OnEvent("FocusLost")] = function()
					self:ValidateValue(self.Object.YOffset.Text, "YOffset")
				end,
			}),
		},
	})

	self:UpdateText()

	-- Add a handler to check if the property we're listening
	-- to has changed
	props.Janitor:Add(props.Object:GetPropertyChangedSignal(props.Property):Connect(function()
		local changedValue: UDim2 = props.Object[props.Property]

		self.XScale = changedValue.X.Scale
		self.XOffset = changedValue.X.Offset
		self.YScale = changedValue.Y.Scale
		self.YOffset = changedValue.Y.Offset

		self:UpdateText()

		props.OnValueChange(changedValue)
	end))

	-- UI cleanup
	props.Janitor:Add(self.Object)

	return self.Object
end
