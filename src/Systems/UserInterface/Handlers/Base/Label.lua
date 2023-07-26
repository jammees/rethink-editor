--[[
	Label.lua

	Simple handler which renders a label.
]]

type Props = {
	--OnValueChange: (boolean) -> (),
	InitialValue: boolean,
	Priority: number,
	Object: GuiBase2d,
	Property: string,
	Janitor: any,
}

local TextService = game:GetService("TextService")

local library = script.Parent.Parent.Parent.Parent.Parent.Library

--local ConfigSystem = require(script.Parent.Parent.Parent.Parent.Config).Get()

local Theme = require(script.Parent.Parent.Parent.Themes).GetTheme()

local Fusion = require(library.Fusion)
--local Children = Fusion.Children
local New = Fusion.New
local Ref = Fusion.Ref
local Value = Fusion.Value

local Label = {}
Label.__index = Label

function Label.new(props: Props)
	local self = setmetatable({}, Label)

	self.Kind = "Label"

	self.Props = props
	self.State = props.InitialValue or 0
	self.MuteChangedSignal = false

	-- References to UI elements
	self.LabelRef = Value()

	self.UI = self:Render()

	--[[ if props.Object then
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
	end ]]

	-- Attach connections and cleanup
	--[[ self:CleanupIf(
		props.Janitor,
		Fusion.peek(self.InputRef).FocusLost:Connect(function()
			self:SetState(Fusion.peek(self.InputRef).Text)
		end)
	) ]]

	self:CleanupIf(props.Janitor, self.UI)

	-- Set inital values
	--self:SetState(self.State)

	return self
end

function Label:CleanupIf(statement: boolean, connection: RBXScriptSignal | RBXScriptConnection)
	if statement then
		self.Props.Janitor:Add(connection)
	end
end

function Label:SetState(newState: number | nil)
	--[[ self.MuteChangedSignal = true

	if newState == nil then
		Fusion.peek(self.InputRef).Text = self.State

		return
	end

	self.State = newState--]]

	Fusion.peek(self.LabelRef).Text = newState

	--[[self.Props.OnValueChange(self.State)

	self.MuteChangedSignal = false--]]

	return self
end

function Label:Render()
	local textSize = TextService:GetTextSize(self.Props.InitialValue, 14, Enum.Font.SourceSans, Vector2.new(350, 90))

	return New("TextLabel")({
		Size = UDim2.new(1, 0, 0, textSize.Y < 20 and 20 or textSize.Y),
		BackgroundTransparency = 1,
		Name = "Label",
		LayoutOrder = self.Props.Priority and self.Props.Priority or 0,

		[Ref] = self.LabelRef,

		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.Text1,

		Text = self.Props.InitialValue,
	})
end

function Label:Get()
	return self.UI
end

return Label
