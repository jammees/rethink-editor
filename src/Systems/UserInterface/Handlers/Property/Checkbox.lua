--[[
	Checkbox.lua

	A handler, which handles booleans.
]]

type Props = {
	Title: string?,
	OnValueChange: (boolean) -> (),
	InitialValue: boolean,
	Priority: number?,
	Object: GuiBase2d?,
	Property: string?,
	Janitor: any?,
}

local TextService = game:GetService("TextService")

local library = script.Parent.Parent.Parent.Parent.Parent.Library

local ConfigSystem = require(script.Parent.Parent.Parent.Parent.Config).Get()

local ICON_SET = require(script.Parent.Parent.Parent.ICON_SET)

local Theme = require(script.Parent.Parent.Parent.Themes).GetTheme()

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New
local Ref = Fusion.Ref
local Value = Fusion.Value

local Checkbox = {}
Checkbox.__index = Checkbox

function Checkbox.new(props: Props)
	props.Title = props.Title or ""

	local self = setmetatable({}, Checkbox)

	self.Kind = "Checkbox"

	self.Props = props
	self.State = props.InitialValue or false
	self.MuteChangedSignal = false

	-- References to UI elements
	self.InputRef = Value()
	self.CheckmarkRef = Value()
	self.BaseRef = Value()

	self.UI = self:Render()

	if props.Object then
		self:CleanupIf(
			props.Janitor,
			props.Object:GetPropertyChangedSignal(props.Property):Connect(function()
				if self.MuteChangedSignal then
					return
				end

				local newValue: boolean = props.Object[props.Property]

				self:SetState(newValue)
			end)
		)
	end

	-- Check if Janitor is provided
	-- Set-up UI logic and cleanup
	self:CleanupIf(
		props.Janitor,
		Fusion.peek(self.InputRef).MouseButton1Click:Connect(function()
			self:SetState(not self.State)
		end)
	)

	-- Cleanup
	self:CleanupIf(props.Janitor, self.UI)

	self:SetState(self.State)

	return self
end

function Checkbox:CleanupIf(statement: boolean, connection: RBXScriptSignal | RBXScriptConnection)
	if statement then
		self.Props.Janitor:Add(connection)
	end
end

function Checkbox:SetState(newState)
	self.MuteChangedSignal = true

	self.State = newState

	Fusion.peek(self.CheckmarkRef).Visible = newState

	self.Props.OnValueChange(newState)

	self.MuteChangedSignal = false

	return self
end

function Checkbox:Render()
	return New("TextButton")({
		Text = "",
		Size = UDim2.new(
			0,
			TextService:GetTextSize(self.Props.Title, 14, Enum.Font.SourceSans, Vector2.new(999, 50)).X + 50,
			0,
			20
		),
		BackgroundTransparency = 1,
		AutoButtonColor = true,
		Name = "Checkbox",
		LayoutOrder = self.Props.Priority and self.Props.Priority or 0,

		[Ref] = self.InputRef,

		[Children] = {
			--[[ Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, ConfigSystem.ui_Property_Handler_Padding_Left:get()),
				--PaddingTop = UDim.new(0, 2.5),
				--PaddingBottom = UDim.new(0, 5),
			}), ]]

			CheckboxContainer = New("Frame")({
				Size = UDim2.fromOffset(15, 15),
				BackgroundColor3 = Theme.BG2,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Name = "CheckboxContainer",

				[Ref] = self.BaseRef,

				[Children] = {
					Checkmark = New("ImageLabel")({
						Image = ICON_SET.checkmark,
						BackgroundTransparency = 1,
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.new(1, -5, 1, -5),
						Name = "Checkmark",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Visible = self.State,
						ImageColor3 = Theme.IconColor,

						[Ref] = self.CheckmarkRef,
					}),
				},
			}),

			Title = New("TextLabel")({
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 20, 0.5, 0),
				Text = self.Props.Title,
				TextColor3 = Theme.Text1,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		},
	})
end

function Checkbox:Get()
	return self.UI
end

return Checkbox
