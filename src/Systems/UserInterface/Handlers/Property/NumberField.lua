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
	CenteredText: boolean?,
}

local CollectionService = game:GetService("CollectionService")

local library = script.Parent.Parent.Parent.Parent.Parent.Library

local ConfigSystem = require(script.Parent.Parent.Parent.Parent.Config).Get()

local ICON_SET = require(script.Parent.Parent.Parent.ICON_SET)

local Theme = require(script.Parent.Parent.Parent.Themes).GetTheme()

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

	self.Kind = "NumberField"

	self.Props = props
	self.State = props.InitialValue or 0
	self.MuteChangedSignal = false
	self.Focused = false

	-- References to UI elements
	self.InputRef = Value()
	self.IncrementRef = Value()
	self.DecrementRef = Value()
	self.BaseRef = Value()

	self.UI = self:Render()

	-- Attach connections and cleanup
	self:CleanupIf(
		props.Janitor,
		Fusion.peek(self.InputRef).FocusLost:Connect(function()
			self:SetState(tonumber(Fusion.peek(self.InputRef).Text))

			warn(ConfigSystem)

			self.Focused = false

			if props.Object then
				warn(ConfigSystem.ui_Handler_IsFocused)
				warn(ConfigSystem.ui_Handler_IsFocused_Ref)
				ConfigSystem.ui_Handler_IsFocused:set(false)
				ConfigSystem.ui_Handler_IsFocused_Ref:set(nil)
			end
		end)
	)

	self:CleanupIf(
		props.Janitor,
		self.UI.MouseWheelForward:Connect(function()
			if not self.Focused then
				return
			end

			self:SetState(self.State + (props.IncrementBy or 1))
		end)
	)

	self:CleanupIf(
		props.Janitor,
		self.UI.MouseWheelBackward:Connect(function()
			if not self.Focused then
				return
			end

			self:SetState(self.State - (props.IncrementBy or 1))
		end)
	)

	self:CleanupIf(
		props.Janitor,
		Fusion.peek(self.InputRef).Focused:Connect(function()
			self.Focused = true

			if props.Object then
				ConfigSystem.ui_Handler_IsFocused:set(true)
				ConfigSystem.ui_Handler_IsFocused_Ref:set(self)
			end
		end)
	)

	if props.Object and props.Property then
		self:CleanupIf(
			props.Janitor,
			props.Object:GetPropertyChangedSignal(props.Property):Connect(function()
				if self.MuteChangedSignal then
					return
				end

				local newValue: number = props.Object[props.Property]

				self:SetState(newValue)
			end)
		)
	end

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
	self.MuteChangedSignal = true

	if newState == nil then
		Fusion.peek(self.InputRef).Text = tostring(self.State)

		return
	end

	self.State = newState

	Fusion.peek(self.InputRef).Text = tostring(newState)

	if noInvoke == false or noInvoke == nil then
		self.Props.OnValueChange(self.State)
	end

	self.MuteChangedSignal = false

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
				BackgroundColor3 = Theme.BG3,
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
				BackgroundColor3 = Theme.BG3,
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
		BackgroundColor3 = Theme.BG2,
		Name = "NumberField",
		LayoutOrder = self.Props.Priority and self.Props.Priority or 0,

		[Ref] = self.BaseRef,

		[Children] = {
			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(
					0,
					self.Props.CenteredText and 0 or ConfigSystem.ui_Property_Handler_Padding_Left:get()
				),
			}),

			Input = New("TextBox")({
				Name = "Input",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, self.Props.DrawArrows and -15 or 0, 1, 0),
				TextColor3 = Theme.Text1,
				TextXAlignment = self.Props.CenteredText and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,

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
