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

local NumberField = require(script.Parent.NumberField)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New
local Ref = Fusion.Ref
local Value = Fusion.Value

local ColorField = {}
ColorField.__index = ColorField

function ColorField.new(props)
	print("new ColorField class")

	local self = setmetatable({}, ColorField)

	self.Props = props
	self.State = { 255, 255, 255 }
	self.Handlers = {}

	-- Convert the number into a range of 0-255 instead of 0-1
	-- Reason is it would be harder to make NumberField display the 0-255
	-- version but store the 0-1 version.
	if props.InitialValue then
		local colorVal: Color3 = props.InitialValue
		self.State = { colorVal.R * 255, colorVal.G * 255, colorVal.B * 255 }
	end

	self.UI = self:Render()

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
	self.State = newState

	print(self.Handlers)

	for i = 1, 3 do
		local handlerClass = self.Handlers[i]

		if not handlerClass then
			continue
		end

		handlerClass:SetState(self.State[i], true)
	end

	self.Props.OnValueChange(Color3.new(table.unpack(self.State)))

	return self
end

function ColorField:Render(): GuiBase2d
	local container = New("Frame")({
		Size = UDim2.new(0, 100, 0, 20),
		BackgroundTransparency = 1,
		Name = "ColorField",
		LayoutOrder = self.Props.Priority and self.Props.Priority or 0,

		[Children] = {
			List = New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5),
			}),
		},
	})

	for i = 1, 3 do
		local handler = NumberField.new({
			Janitor = self.Props.Janitor or nil,
			InitialValue = self.State[i],
			Priority = i,
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

				print(table.unpack(newState))
			end,
		})

		handler:Get().Parent = container
		handler:Get().Size = UDim2.fromScale(0.33, 1)

		self.Handlers[i] = handler
	end

	return container
end

function ColorField:Get()
	return self.UI
end

return ColorField

--[[
return function(props: Props)
	props.OnValueChange = props.OnStateChange ~= nil and props.OnStateChange or props.OnValueChang

	local self = setmetatable({}, {})

	self.ValueR = props.InitialValue.R or 255
	self.ValueG = props.InitialValue.G or 255
	self.ValueB = props.InitialValue.B or 255

	-- Convert the unit to 255
	if props.InitialValue then
		self.ValueR *= 255
		self.ValueG *= 255
		self.ValueB *= 255
	end

	self.UpdateText = function(s)
		s.Object.InputR.Text = tostring(math.floor(self.ValueR))
		s.Object.InputG.Text = tostring(math.floor(self.ValueG))
		s.Object.InputB.Text = tostring(math.floor(self.ValueB))
	end

	self.Object = New("Frame")({
		Size = UDim2.new(0, 100, 0, 20),
		BackgroundTransparency = 1,
		Name = "NumberField",
		LayoutOrder = props.Priority and props.Priority or 0,

		[Children] = {
			List = New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2.5),
			}),

			InputR = New("TextBox")({
				Name = "InputR",
				Size = UDim2.new(0.33, 0, 1, 0),
				TextColor3 = Color3.fromHex("F15959"),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = USE_COLOR and Color3.fromHex("DD3F3F") or DEF_COLOR,
				LayoutOrder = 1,

				[Fusion.OnEvent("FocusLost")] = function()
					local newInput = tonumber(math.floor(self.Object.InputR.Text))
					local onlyNums = doesOnlyContainNums(string.lower(tostring(newInput)))
					newInput = math.clamp(newInput, 0, 255)

					if onlyNums and tostring(newInput):len() <= 3 then
						self.ValueR = newInput

						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					else
						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					end
				end,
			}),

			InputG = New("TextBox")({
				Name = "InputG",
				Size = UDim2.new(0.33, 0, 1, 0),
				TextColor3 = Color3.fromHex("6CE362"),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = USE_COLOR and Color3.fromHex("43C538") or DEF_COLOR,
				LayoutOrder = 2,

				[Fusion.OnEvent("FocusLost")] = function()
					local newInput = tonumber(math.floor(self.Object.InputG.Text))
					local onlyNums = doesOnlyContainNums(string.lower(tostring(newInput)))
					newInput = math.clamp(newInput, 0, 255)

					if onlyNums and tostring(newInput):len() <= 3 then
						self.ValueG = newInput

						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					else
						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					end
				end,
			}),

			InputB = New("TextBox")({
				Name = "InputB",
				Size = UDim2.new(0.33, 0, 1, 0),
				TextColor3 = Color3.fromHex("4E81EE"),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundColor3 = USE_COLOR and Color3.fromHex("385FC5") or DEF_COLOR,
				LayoutOrder = 3,

				[Fusion.OnEvent("FocusLost")] = function()
					local newInput = tonumber(math.floor(self.Object.InputB.Text))
					local onlyNums = doesOnlyContainNums(string.lower(tostring(newInput)))
					newInput = math.clamp(newInput, 0, 255)

					if onlyNums and tostring(newInput):len() <= 3 then
						self.ValueB = newInput

						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					else
						props.OnValueChange(Color3.fromRGB(self.ValueR, self.ValueG, self.ValueB))
						self:UpdateText()
					end
				end,
			}),
		},
	})

	self:UpdateText()

	return self.Object
end--]]
