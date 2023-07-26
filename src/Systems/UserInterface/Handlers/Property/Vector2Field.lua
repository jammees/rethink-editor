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

local Vector2Field = {}
Vector2Field.__index = Vector2Field

function Vector2Field.new(props: Props)
	local self = setmetatable({}, Vector2Field)

	self.Kind = "Vector2Field"

	self.Props = props
	self.State = { props.InitialValue.X, props.InitialValue.Y }
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

				local newValue: Vector2 = props.Object[props.Property]

				self:SetState({ newValue.X, newValue.Y })
			end)
		)
	end

	self:CleanupIf(props.Janitor, self.UI)

	-- Set inital values
	self:SetState(self.State)

	return self
end

function Vector2Field:CleanupIf(statement: boolean, connection: RBXScriptSignal | RBXScriptConnection)
	if statement then
		self.Props.Janitor:Add(connection)
	end
end

function Vector2Field:SetState(newState: { number })
	self.MuteChangedSignal = true

	self.State = newState

	for i = 1, #self.Handlers do
		local handlerClass = self.Handlers[i]

		if not handlerClass then
			continue
		end

		handlerClass:SetState(self.State[i], true)
	end

	self.Props.OnValueChange(Vector2.new(table.unpack(self.State)))

	self.MuteChangedSignal = false

	return self
end

function Vector2Field:Render(): GuiBase2d
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

	for i = 1, 2 do
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

function Vector2Field:Get()
	return self.UI
end

return Vector2Field
