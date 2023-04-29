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

local ICON_SET = require(script.Parent.Parent.Parent.ICON_SET)

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

	self.Props = props
	self.State = props.InitialValue or 0

	-- References to UI elements
	self.InputRef = Value()
	self.UI = self:Render()

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
	if newState == nil then
		Fusion.peek(self.InputRef).Text = self.State

		return
	end

	self.State = newState

	Fusion.peek(self.InputRef).Text = newState

	self.Props.OnValueChange(self.State)

	return self
end

function StringField:Render()
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
				Size = UDim2.new(1, 0, 1, 0),
				TextColor3 = Color3.fromRGB(255, 255, 255),
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
