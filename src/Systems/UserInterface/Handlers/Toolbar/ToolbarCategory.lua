--[[
	toolbarCategory.lua

	A toolbar handler, which groups up handlers inside it.
	Supports handlers inside handlers.
]]

type Props = {
	Handlers: {},
	Title: string,
	Separator: string,
	Direction: Enum.FillDirection,
	Priority: number,
	Janitor: any,
}

local TextService = game:GetService("TextService")

local library = script.Parent.Parent.Parent.Parent.Parent.Library

local Theme = require(script.Parent.Parent.Parent.Themes).GetTheme()

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

return function(props: Props)
	local container = New("Frame")({
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0, 1),
		Name = "Category",
		LayoutOrder = props.Priority and props.Priority or 0,

		[Children] = {
			Handlers = New("Frame")({
				Size = UDim2.fromScale(1, 1),
				Name = "Handlers",
				BackgroundTransparency = 1,

				[Children] = {
					List = New("UIListLayout")({
						FillDirection = Fusion.peek(props.Direction) ~= nil and props.Direction
							or Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					Padding = New("UIPadding")({
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
					}),
				},
			}),

			Padding = New("UIPadding")({
				PaddingBottom = UDim.new(0, 5),
			}),
		},
	})

	if props.Separator and props.Separator:find("left") then
		New("Frame")({
			BackgroundColor3 = Theme.BG3,
			Size = UDim2.new(0, 1.5, 1, 0),
			Name = "Separator",
			Parent = container,
		})
	end

	if props.Separator and props.Separator:find("right") then
		New("Frame")({
			BackgroundColor3 = Theme.BG3,
			Size = UDim2.new(0, 1.5, 1, 0),
			Position = UDim2.fromScale(1, 0),
			Name = "Separator",
			Parent = container,
		})
	end

	if props.Title ~= nil then
		local textSize = TextService:GetTextSize(props.Title, 14, Enum.Font.SourceSans, container.AbsoluteSize)

		New("TextLabel")({
			Text = props.Title,
			AnchorPoint = Vector2.new(0.5, 1),
			Size = UDim2.fromOffset(textSize.X, textSize.Y > 25 and textSize.Y or 25),
			Position = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
			TextColor3 = Theme.Text1,
			Parent = container,
			Name = "CName",
		})

		container.Handlers.Size = UDim2.new(1, 0, 1, -25)
	end

	for _, handler: GuiBase2d in ipairs(props.Handlers) do
		handler.Parent = container.Handlers

		if handler:GetAttribute("ResizeInToolbar") then
			handler.Size = UDim2.new(handler.Size.X.Scale, handler.Size.X.Offset, 1, 0)
			handler.UIPadding.PaddingBottom = UDim.new(0, 0)
		end

		if container:FindFirstChild("CName") then
			if container.Size.X.Offset < container.CName.Size.X.Offset then
				container.Size = UDim2.new(0, container.CName.Size.X.Offset + 10, 1, 0)
			end
		end

		if handler.Size.X.Offset > container.Size.X.Offset then
			container.Size = UDim2.new(0, handler.Size.X.Offset + 10 + container.Size.X.Offset, 1, 0)
		end
	end

	return container
end
