local library = script.Parent.Parent.Parent.Parent.Parent.Library

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New
local Ref = Fusion.Ref
local Value = Fusion.Value

local NumberField = {}
NumberField.__index = NumberField

function NumberField.new(props)
	local self = setmetatable({}, NumberField)

	self.Props = props
	self.State = props.InitialValue or 0

	self.UI = self:Render()

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

function NumberField:SetState(newState: number | nil)
	if newState == nil then
		Fusion.peek(self.InputRef).Text = tostring(self.State)

		return
	end

	self.State = newState

	Fusion.peek(self.InputRef).Text = tostring(newState)

	self.Props.OnValueChange(self.State)

	return self
end

function NumberField:Render(): GuiBase2d
	return
end

function NumberField:Get()
	return self.UI
end

return NumberField
