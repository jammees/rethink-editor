type Props = {
	InitialState: boolean,
	Priority: number,
	Object: any,
	Property: string,
}

local library = script.Parent.Parent.Parent.Parent.Library

local ICON_SET = require(script.Parent.Parent.ICON_SET)
local ObjectSystem = require(script.Parent.Parent.Parent.Object)
local Value = require(script.Parent.Parent.Parent.Config.Value)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

return function(props: Props)
	local self = setmetatable({}, {})

	self.State = Value.new(props.InitialState or false)
	self.ObjectRef = ObjectSystem.GetFromObject(props.Object)

	self.Property = props.Property

	self.State:onChange(function(newState: boolean)
		self.ObjectRef.Object[self.Property] = newState
		self.ObjectRef.ExportData[self.Property] = newState
	end)

	if props.InitialState then
		self.ObjectRef.Object[self.Property] = props.InitialState
	end

	self.Object = New("TextButton")({
		Text = "",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
		AutoButtonColor = true,
		Name = "",
		LayoutOrder = props.Priority and props.Priority or 0,

		[Children] = {
			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
			}),

			Title = New("TextLabel")({
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 5, 0.5, 0),
				Text = props.Property,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			Promt = New("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.5, 1),
				Position = UDim2.fromScale(0.5, 0),
				Name = "Promt",

				[Children] = {
					Padding = New("UIPadding")({
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5),
					}),

					CheckboxContainer = New("Frame")({
						Size = UDim2.fromOffset(20, 20),
						BackgroundColor3 = Color3.fromRGB(22, 22, 22),
						Name = "CheckboxContainer",

						[Children] = {
							Checkmark = New("ImageLabel")({
								Image = ICON_SET.ICON_SET_OBJ_ARROW.ICON_SET_ID,
								ImageRectSize = Vector2.new(42, 39),
								ImageRectOffset = ICON_SET.ICON_SET_OBJ_ARROW.ICON_SET_MAP.checkmark,
								BackgroundTransparency = 1,
								ScaleType = Enum.ScaleType.Fit,
								Size = UDim2.new(1, -5, 1, -5),
								Name = "Checkmark",
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Visible = self.State:get(),
							}),
						},
					}),
				},
			}),
		},

		[Fusion.OnEvent("MouseButton1Click")] = function()
			self.State:set(not self.State:get())

			self.Object.Promt.CheckboxContainer.Checkmark.Visible = self.State:get()
		end,
	})

	return self.Object
end
