local DataStoreService = game:GetService("DataStoreService")
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

local ColorField = {}
ColorField.__index = ColorField

function ColorField.new(props: Props)
	local self = setmetatable({}, ColorField)

	self.Kind = "ColorField"

	self.Props = props
	self.State = { 255, 255, 255 }
	self.Handlers = {}
	self.MuteChangedSignal = false

	-- Convert the number into a range of 0-255 instead of 0-1
	-- Reason is it would be harder to make NumberField display the 0-255
	-- version but store the 0-1 version.
	if props.InitialValue then
		local colorVal: Color3 = props.InitialValue
		self.State = { colorVal.R * 255, colorVal.G * 255, colorVal.B * 255 }
	end

	self.UI = self:Render()

	if props.Object then
		self:CleanupIf(
			props.Janitor,
			props.Object:GetPropertyChangedSignal(props.Property):Connect(function()
				if self.MuteChangedSignal then
					require(script.Parent.Parent.Parent.Parent.LoggerV1).Log(
						"ColorField",
						2,
						`:GetPropertyChangedSignal muted!`
					)
					return
				end

				local newValue: Color3 = props.Object[props.Property]
				local newState = { newValue.R, newValue.G, newValue.B }

				self:SetState(newState)
			end)
		)
	end

	self:CleanupIf(props.Janitor, self.UI)

	-- Set inital values
	self:SetState(self.State)

	return self
end

function ColorField:CleanupIf(statement: boolean, connection: RBXScriptSignal | RBXScriptConnection)
	if statement then
		self.Props.Janitor:Add(connection)
	end
end

function ColorField:SetState(newState: { number })
	self.MuteChangedSignal = true

	self.State = newState

	for i = 1, #self.Handlers do
		local handlerClass = self.Handlers[i]

		if not handlerClass then
			continue
		end

		handlerClass:SetState(self.State[i], true)
	end

	self.Props.OnValueChange(Color3.fromRGB(table.unpack(self.State)))

	self.MuteChangedSignal = false

	return self
end

function ColorField:Render(): GuiBase2d
	local container = New("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Name = "ColorField",
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

function ColorField:Get()
	return self.UI
end

return ColorField
