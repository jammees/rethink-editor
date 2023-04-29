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

local ICON_SET = require(script.Parent.Parent.Parent.ICON_SET)

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

	self.Props = props
	self.State = props.InitialValue or false

	-- References to UI elements
	self.CheckmarkRef = Value()
	self.UI = self:Render()

	-- Check if Janitor is provided
	-- Set-up UI logic and cleanup
	self:CleanupIf(
		props.Janitor,
		self.UI.MouseButton1Click:Connect(function()
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
	self.State = newState

	Fusion.peek(self.CheckmarkRef).Visible = newState

	self.Props.OnValueChange(newState)

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
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
		AutoButtonColor = true,
		Name = "Checkbox",
		LayoutOrder = self.Props.Priority and self.Props.Priority or 0,

		[Children] = {
			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 3),
				--PaddingTop = UDim.new(0, 2.5),
				--PaddingBottom = UDim.new(0, 5),
			}),

			CheckboxContainer = New("Frame")({
				Size = UDim2.fromOffset(15, 15),
				BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Name = "CheckboxContainer",

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
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		},
	})
end

function Checkbox:Get()
	return self.UI
end

return Checkbox
