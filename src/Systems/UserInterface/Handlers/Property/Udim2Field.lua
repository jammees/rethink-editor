--[[
	colorField.lua

	A property handler, which accepts three numbers for R, G and B.
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

local NumberField = require(script.Parent.NumberField)
local Unifier = require(script.Parent.Parent.Unifier)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

local Udim2Field = {}
Udim2Field.__index = Udim2Field

function Udim2Field.new(props: Props)
	local self = setmetatable({}, Udim2Field)

	self.Kind = "Udim2Field"

	self.Props = props
	self.State = {
		props.InitialValue.X.Scale,
		props.InitialValue.X.Offset,
		props.InitialValue.Y.Scale,
		props.InitialValue.Y.Offset,
	}
	self.Handlers = {}
	self.MuteChangedSignal = false

	self.UI = self:Render()

	if props.Object then
		self:CleanupIf(
			props.Janitor,
			props.Object:GetPropertyChangedSignal(props.Property):Connect(function()
				if self.MuteChangedSignal then
					return
				end

				local newValue: UDim2 = props.Object[props.Property]

				self:SetState({ newValue.X.Scale, newValue.X.Offset, newValue.Y.Scale, newValue.Y.Offset })
			end)
		)
	end

	self:CleanupIf(props.Janitor, self.UI)

	-- Set inital values
	self:SetState(self.State)

	return self
end

function Udim2Field:CleanupIf(statement: boolean, connection: RBXScriptSignal | RBXScriptConnection)
	if statement then
		self.Props.Janitor:Add(connection)
	end
end

function Udim2Field:SetState(newState: { number })
	self.MuteChangedSignal = true

	self.State = newState

	for i = 1, #self.Handlers do
		local handlerClass = self.Handlers[i]

		if not handlerClass then
			continue
		end

		handlerClass:SetState(self.State[i], true)
	end

	self.Props.OnValueChange(UDim2.new(table.unpack(self.State)))

	self.MuteChangedSignal = false

	return self
end

function Udim2Field:Render(): GuiBase2d
	local container = New("Frame")({
		Size = UDim2.new(0, 100, 0, 20),
		BackgroundTransparency = 1,
		Name = "Udim2Field",
		LayoutOrder = self.Props.Priority and self.Props.Priority or 0,

		[Children] = {
			List = New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, ConfigSystem.ui_Property_Handler_Padding_Spacer:get()),
			}),
		},
	})

	for i = 1, 4 do
		local handler = NumberField.new({
			Janitor = self.Props.Janitor or nil,
			InitialValue = self.State[i],
			CenteredText = true,
			Priority = i,
			Object = self.Props.Object,
			OnValueChange = function(newValue)
				local newState = table.clone(self.State)
				newState[i] = newValue

				self:SetState(newState)
			end,
		})

		handler:Get().Parent = container

		self.Handlers[i] = handler
	end

	Unifier.relativeSize(Unifier.GetHandlerUIs(self.Handlers), container)

	return container
end

function Udim2Field:Get()
	return self.UI
end

return Udim2Field
