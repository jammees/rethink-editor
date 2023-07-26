--[[
	Vector3Field.lua

	A property handler, which accepts three numbers for X, Y and Z.
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

local Vector3Field = {}
Vector3Field.__index = Vector3Field

function Vector3Field.new(props: Props)
	local self = setmetatable({}, Vector3Field)

	self.Kind = "Vector3Field"

	self.Props = props
	self.State = { props.InitialValue.X, props.InitialValue.Y, props.InitialValue.Z }
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

				local newValue: Vector3 = props.Object[props.Property]

				self:SetState({ newValue.X, newValue.Y, newValue.Z })
			end)
		)
	end

	self:CleanupIf(props.Janitor, self.UI)

	-- Set inital values
	self:SetState(self.State)

	return self
end

function Vector3Field:CleanupIf(statement: boolean, connection: RBXScriptSignal | RBXScriptConnection)
	if statement then
		self.Props.Janitor:Add(connection)
	end
end

function Vector3Field:SetState(newState: { number })
	self.MuteChangedSignal = true

	self.State = newState

	for i = 1, #self.Handlers do
		local handlerClass = self.Handlers[i]

		if not handlerClass then
			continue
		end

		handlerClass:SetState(self.State[i], true)
	end

	self.Props.OnValueChange(Vector3.new(table.unpack(self.State)))

	self.MuteChangedSignal = false

	return self
end

function Vector3Field:Render(): GuiBase2d
	local container = New("Frame")({
		Size = UDim2.new(0, 100, 0, 20),
		BackgroundTransparency = 1,
		Name = "Vector3Field",
		LayoutOrder = self.Props.Priority and self.Props.Priority or 0,

		[Children] = {
			List = New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, ConfigSystem.ui_Property_Handler_Padding_Spacer:get()),
			}),
		},
	})

	for i = 1, 3 do
		local handler = NumberField.new({
			Janitor = self.Props.Janitor or nil,
			InitialValue = self.State[i],
			CenteredText = true,
			Priority = i,
			Object = self.Props.Object,
			OnValueChange = function(newValue)
				if NumberField.IsFloat(newValue) then
					newValue = math.floor(newValue)
				end

				if (0 <= newValue and newValue <= 255) == false then
					newValue = math.clamp(newValue, 0, 255)
				end

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

function Vector3Field:Get()
	return self.UI
end

return Vector3Field
