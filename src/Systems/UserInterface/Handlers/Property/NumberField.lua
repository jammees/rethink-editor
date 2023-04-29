--[[
	NumberField.lua

	A handler, which accepts only numbers as input.
	Includes arrows on the right side to increment/decrement the value.
]]

type Props = {
	OnValueChange: (boolean) -> (),
	InitialValue: boolean,
	Priority: number?,
	IncrementBy: number?,
	Range: NumberRange?,
	Object: GuiBase2d?,
	Property: string?,
	Janitor: any?,
	DrawArrows: boolean?,
}

local library = script.Parent.Parent.Parent.Parent.Parent.Library

local ICON_SET = require(script.Parent.Parent.Parent.ICON_SET)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New
local Ref = Fusion.Ref
local Value = Fusion.Value

function IsNumber(inputString)
	local loweredInput = string.lower(inputString)

	for i = 1, #loweredInput do
		if string.match(string.sub(loweredInput, i, i), "%d") == nil and string.sub(loweredInput, i, i) ~= "." then
			return false -- found character that is not a number
		end
	end

	return true -- all are numbers
end

function IsFloat(inputString: string)
	local loweredInput = string.lower(inputString)

	for i = 1, #loweredInput do
		if string.sub(loweredInput, i, i) == "." then
			return true
		end
	end

	return false
end

local NumberField = {}
NumberField.__index = NumberField

NumberField.IsNumber = IsNumber
NumberField.IsFloat = IsFloat

function NumberField.new(props: Props)
	local self = setmetatable({}, NumberField)

	self.Props = props
	self.State = props.InitialValue or 0

	-- References to UI elements
	self.InputRef = Value()
	self.IncrementRef = Value()
	self.DecrementRef = Value()
	self.UI = self:Render()

	-- Attach connections and cleanup
	self:CleanupIf(
		props.Janitor,
		Fusion.peek(self.InputRef).FocusLost:Connect(function()
			self:SetState(tonumber(Fusion.peek(self.InputRef).Text))
		end)
	)

	if self.DrawArrows then
		self:CleanupIf(
			props.Janitor,
			Fusion.peek(self.IncrementRef).MouseButton1Click:Connect(function()
				self:SetState(self.State + 1)
			end)
		)

		self:CleanupIf(
			props.Janitor,
			Fusion.peek(self.DecrementRef).MouseButton1Click:Connect(function()
				self:SetState(self.State - 1)
			end)
		)
	end

	self:CleanupIf(props.Janitor, self.UI)

	-- Set inital values
	self:SetState(self.State)

	return self
end

function NumberField:CleanupIf(statement: boolean, connection: RBXScriptSignal | RBXScriptConnection)
	if statement then
		self.Props.Janitor:Add(connection)
	end
end

function NumberField:SetState(newState: number | nil, noInvoke: boolean)
	if newState == nil then
		Fusion.peek(self.InputRef).Text = tostring(self.State)

		return
	end

	self.State = newState

	Fusion.peek(self.InputRef).Text = tostring(newState)

	if noInvoke == false or noInvoke == nil then
		self.Props.OnValueChange(self.State)
	end

	return self
end

function NumberField:Render()
	local function DrawArrows()
		if not self.Props.DrawArrows then
			return
		end

		return table.unpack({
			Increment = New("TextButton")({
				Name = "Increment",
				Size = UDim2.new(0, 15, 0.5, -0.5),
				Position = UDim2.new(1, 0, 0, 0),
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				BorderSizePixel = 0,
				AutoButtonColor = true,
				Text = "",

				[Ref] = self.IncrementRef,

				[Children] = {
					Icon = New("ImageLabel")({
						Image = ICON_SET.up_arrow_thin,
						BackgroundTransparency = 1,
						Size = UDim2.fromOffset(12, 12),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						ScaleType = Enum.ScaleType.Fit,
					}),
				},
			}),

			Decrement = New("TextButton")({
				Name = "Decrement",
				Size = UDim2.new(0, 15, 0.5, -0.5),
				Position = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(1, 1),
				BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				BorderSizePixel = 0,
				AutoButtonColor = true,
				Text = "",

				[Ref] = self.DecrementRef,

				[Children] = {
					Icon = New("ImageLabel")({
						Image = ICON_SET.down_arrow_thin,
						BackgroundTransparency = 1,
						Size = UDim2.fromOffset(12, 12),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						ScaleType = Enum.ScaleType.Fit,
					}),
				},
			}),
		})
	end

	return New("Frame")({
		Size = UDim2.new(0, 100, 0, 20),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		Name = "NumberField",
		LayoutOrder = self.Props.Priority and self.Props.Priority or 0,

		[Children] = {
			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 3),
			}),

			Input = New("TextBox")({
				Name = "Input",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -15, 1, 0),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Left,

				[Ref] = self.InputRef,
			}),

			DrawArrows(),
		},
	})
end

function NumberField:Get()
	return self.UI
end

return NumberField

--[[ return function(props: Props)
	props.OnValueChange = props.OnStateChange ~= nil and props.OnStateChange or props.OnValueChange

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
--[[

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
				Size = UDim2.new(0, 20, 0.5, -0.5),
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
						Image = ICON_SET.up_arrow_thin,
						BackgroundTransparency = 1,
						Size = UDim2.fromOffset(15, 15),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						ScaleType = Enum.ScaleType.Fit,
					}),
				},
			}),

			IncrementDown = New("TextButton")({
				Size = UDim2.new(0, 20, 0.5, -0.5),
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
						Image = ICON_SET.down_arrow_thin,
						BackgroundTransparency = 1,
						Size = UDim2.fromOffset(15, 15),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						ScaleType = Enum.ScaleType.Fit,
					}),
				},
			}),
		},
	})

	self:UpdateText()

	return self.Object
end
 ]]
