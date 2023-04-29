--[[
	propertyCategory.lua

	An utility handler for property, which categorizes the handlers into groups.
]]

type Props = {
	Name: string,
	Janitor: any,
}

local library = script.Parent.Parent.Parent.Parent.Library

local ICON_SET = require(script.Parent.Parent.ICON_SET)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New
local Value = Fusion.Value
local Ref = Fusion.Ref
local Peek = Fusion.peek

local propertyCategory = {}
propertyCategory.__index = propertyCategory

function propertyCategory.new(props: Props)
	local self = {}

	self.Props = props
	self.Handlers = {}
	self.Janitor = props.Janitor

	self._IconRef = Value()
	self._ButtonRef = Value()
	self._CategoryRef = Value()
	self.IsOpen = true

	self.Ui = New("Frame")({
		BackgroundTransparency = 1,
		Name = "Category",
		Size = UDim2.new(1, 0, 0, 25),

		AutomaticSize = Enum.AutomaticSize.Y,

		[Children] = {
			ButtonContainer = New("TextButton")({
				BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				Size = UDim2.new(1, 0, 0, 25),
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
						Text = props.Name,
						Size = UDim2.new(1, -13, 1, 0),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Position = UDim2.fromOffset(20, 0),
					}),

					Icon = New("ImageLabel")({
						Image = ICON_SET.up_arrow_thin,
						BackgroundTransparency = 1,
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromOffset(13, 13),
						Position = UDim2.new(0, 0, 0.5, 0),
						Name = "Icon",
						AnchorPoint = Vector2.new(0, 0.5),
						Visible = self.State,

						[Fusion.Ref] = self._IconRef,
					}),
				},
			}),

			HandlerContainer = New("Frame")({
				BackgroundTransparency = 1,
				Name = "HandlerContainer",
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.fromOffset(0, 25),

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
	self.Janitor:Add(Peek(self._ButtonRef).MouseButton1Click:Connect(function()
		self.IsOpen = not self.IsOpen

		Peek(self._CategoryRef).Visible = self.IsOpen

		if self.IsOpen then
			self.Ui.AutomaticSize = Enum.AutomaticSize.Y
			Peek(self._IconRef).Image = ICON_SET.up_arrow_thin
		else
			self.Ui.AutomaticSize = Enum.AutomaticSize.None
			Peek(self._IconRef).Image = ICON_SET.down_arrow_thin
		end
	end))

	self.Janitor:Add(self.Ui)
	self.Janitor:Add(function()
		self._IconRef = nil
		self._ButtonRef = nil
		self._CategoryRef = nil
		self.IsOpen = nil
	end)

	return setmetatable(self, propertyCategory)
end

function propertyCategory:GetUI()
	return self.Ui
end

function propertyCategory:Add(handler: any)
	handler.Parent = Peek(self._CategoryRef)
end

function propertyCategory:Destroy()
	self.Janitor:Cleanup()
end

return propertyCategory
