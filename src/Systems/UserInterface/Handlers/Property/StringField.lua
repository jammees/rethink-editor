--[[
	StringField.lua

	A handler, which accepts any string as input.
]]

type Props = {
	OnValueChange: (boolean) -> (),
	InitialValue: boolean,
	Priority: number,
	Object: GuiBase2d,
	Property: string,
	Janitor: any,
}

local library = script.Parent.Parent.Parent.Parent.Parent.Library

local ConfigSystem = require(script.Parent.Parent.Parent.Parent.Config).Get()

local Theme = require(script.Parent.Parent.Parent.Themes).GetTheme()

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New
local Ref = Fusion.Ref
local Value = Fusion.Value

local StringField = {}
StringField.__index = StringField

function StringField.new(props: Props)
	props.OnStateChange = props.OnStateChange and props.OnStateChange
		or function()
			warn("[Editor] .OnStateChange callback was not attached to handler: StringField", debug.traceback())
		end

	local self = setmetatable({}, StringField)

	self.Kind = "StringField"

	self.Props = props
	self.State = props.InitialValue or 0
	self.MuteChangedSignal = false

	-- References to UI elements
	self.InputRef = Value()
	self.BaseRef = Value()

	self.UI = self:Render()

	if props.Object then
		self:CleanupIf(
			props.Janitor,
			props.Object:GetPropertyChangedSignal(props.Property):Connect(function()
				if self.MuteChangedSignal then
					return
				end

				local newValue: string = props.Object[props.Property]

				self:SetState(newValue)
			end)
		)
	end

	-- Attach connections and cleanup
	self:CleanupIf(
		props.Janitor,
		Fusion.peek(self.InputRef).FocusLost:Connect(function()
			self:SetState(Fusion.peek(self.InputRef).Text)
		end)
	)

	self:CleanupIf(props.Janitor, self.UI)

	-- Set inital values
	self:SetState(self.State)

	return self
end

function StringField:CleanupIf(statement: boolean, connection: RBXScriptSignal | RBXScriptConnection)
	if statement then
		self.Props.Janitor:Add(connection)
	end
end

function StringField:SetState(newState: number | nil)
	self.MuteChangedSignal = true

	if newState == nil then
		Fusion.peek(self.InputRef).Text = self.State

		return
	end

	self.State = newState

	Fusion.peek(self.InputRef).Text = newState

	self.Props.OnValueChange(self.State)

	self.MuteChangedSignal = false

	return self
end

function StringField:Render()
	return New("Frame")({
		Size = UDim2.new(0, 100, 0, 20),
		BackgroundColor3 = Theme.BG2,
		Name = "NumberField",
		LayoutOrder = self.Props.Priority and self.Props.Priority or 0,

		[Ref] = self.BaseRef,

		[Children] = {
			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, ConfigSystem.ui_Property_Handler_Padding_Left:get()),
			}),

			Input = New("TextBox")({
				Name = "Input",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				TextColor3 = Theme.Text1,
				TextXAlignment = Enum.TextXAlignment.Left,

				[Ref] = self.InputRef,
			}),
		},
	})
end

function StringField:Get()
	return self.UI
end

return StringField
