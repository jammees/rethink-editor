--[[
	propertyCategory.lua

	An utility handler for property, which categorizes the handlers into groups.
]]

type Props = {
	Name: string,
	Elements: { any },
	Janitor: any,
	Constructor: any,
	OnValueChange: (any) -> any,
}

local library = script.Parent.Parent.Parent.Parent.Parent.Library

local ICON_SET = require(script.Parent.Parent.Parent.ICON_SET)

local Theme = require(script.Parent.Parent.Parent.Themes).GetTheme()

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New
local Value = Fusion.Value
local Ref = Fusion.Ref
local Peek = Fusion.peek

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(props: Props)
	local self = setmetatable({}, Dropdown)

	self.Props = props
	self.Elements = self.Props.Elements
	self.Janitor = props.Janitor

	self._IconRef = Value()
	self._ButtonRef = Value()
	self._CategoryRef = Value()
	self._TitleRef = Value()
	self.IsOpen = false

	self.Ui = New("Frame")({
		BackgroundTransparency = 1,
		Name = self.Props.Name,
		Size = UDim2.new(1, 0, 0, 25),

		AutomaticSize = Enum.AutomaticSize.None,

		[Children] = {
			ButtonContainer = New("TextButton")({
				BackgroundColor3 = Theme.BG2,
				Size = UDim2.new(1, 0, 1, 0),
				Name = "ButtonContainer",
				AutoButtonColor = true,
				Text = "",

				[Ref] = self._ButtonRef,

				[Children] = {
					Padding = New("UIPadding")({
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5),
					}),

					Title = New("TextLabel")({
						Text = self.Props.Name,
						Size = UDim2.new(1, -13, 1, 0),
						BackgroundTransparency = 1,
						TextColor3 = Theme.Text1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Position = UDim2.fromOffset(20, 0),

						[Ref] = self._TitleRef,
					}),

					Icon = New("ImageLabel")({
						Image = ICON_SET.down_arrow_thin,
						BackgroundTransparency = 1,
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromOffset(13, 13),
						Position = UDim2.new(0, 0, 0.5, 0),
						Name = "Icon",
						AnchorPoint = Vector2.new(0, 0.5),
						ImageColor3 = Theme.IconColor,
						Visible = self.State,

						[Fusion.Ref] = self._IconRef,
					}),
				},
			}),

			HandlerContainer = New("Frame")({
				BackgroundColor3 = Theme.BG3,
				Name = "HandlerContainer",
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.fromOffset(0, 25),
				ZIndex = 999,
				Visible = false,

				[Ref] = self._CategoryRef,

				[Children] = {
					List = New("UIListLayout")({
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0, 5),
					}),

					Padding = New("UIPadding")({
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
					}),
				},
			}),
		},
	})

	-- Setup closing and opening of the category
	self.Props.Janitor:Add(
		props.Janitor,
		(
			Peek(self._ButtonRef).MouseButton1Click:Connect(function()
				self.IsOpen = not self.IsOpen

				Peek(self._CategoryRef).Visible = self.IsOpen

				if self.IsOpen then
					Fusion.peek(self._CategoryRef).AutomaticSize = Enum.AutomaticSize.Y
					Peek(self._IconRef).Image = ICON_SET.up_arrow_thin
				else
					Fusion.peek(self._CategoryRef).AutomaticSize = Enum.AutomaticSize.None
					Peek(self._IconRef).Image = ICON_SET.down_arrow_thin
				end
			end)
		)
	)

	self.Props.Janitor:Add(props.Janitor, self.Ui)
	self.Props.Janitor:Add(props.Janitor, function()
		self._IconRef = nil
		self._ButtonRef = nil
		self._CategoryRef = nil
		self.IsOpen = nil
	end)

	for _, element in self.Elements do
		New("TextButton")({
			BackgroundColor3 = Theme.BG3,
			TextColor3 = Theme.Text1,
			Size = UDim2.new(1, 0, 0, 25),
			Text = element,
			ZIndex = 9999999,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = true,

			Parent = Fusion.peek(self._CategoryRef),

			[Fusion.OnEvent("MouseButton1Click")] = function()
				Fusion.peek(self._TitleRef).Text = element
				self.Props.OnValueChange(element)

				self.IsOpen = false
				Fusion.peek(self._CategoryRef).AutomaticSize = Enum.AutomaticSize.None
				Peek(self._IconRef).Image = ICON_SET.down_arrow_thin
				Peek(self._CategoryRef).Visible = self.IsOpen
			end,
		})
	end

	return self
end

function Dropdown:GetUI()
	return self.Ui
end

function Dropdown:Destroy()
	self.Janitor:Cleanup()
end

return Dropdown
