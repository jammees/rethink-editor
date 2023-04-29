-- I've never written such a jank before.
-- God forgive me.

local DARKENING_SELECTED_AMOUNT_THINGY = 50
local ICON_SET_ID = "rbxassetid://12704209971"

local library = script.Parent.Parent.Parent.Parent.Parent.Library

local UserInterfaceSystem = require(script.Parent.Parent.Parent.Parent.UserInterface)

local ICON_SET = require(script.Parent.Parent.Parent.Parent.UserInterface.ICON_SET)
local Signal = require(library.Signal)
local Janitor = require(library.Janitor)
local Fusion = require(library.Fusion)
local New = Fusion.New
local OnEvent = Fusion.OnEvent

local DraggerBase = {}
DraggerBase.__index = DraggerBase

function DraggerBase.new(object: GuiBase2d)
	local self = setmetatable({}, DraggerBase)

	self.Janitor = Janitor.new()
	self.DragStart = Signal.new()
	self.DragEnd = Signal.new()
	self.Object = object

	self.XYDragger = New("TextButton")({
		Name = "XYDragger",
		Parent = UserInterfaceSystem.UI,
		ZIndex = 99999991,
		Size = UDim2.fromOffset(15, 15),
		Position = UDim2.fromOffset(
			object.AbsolutePosition.X + object.AbsoluteSize.X / 2 - 5.25,
			object.AbsolutePosition.Y + object.AbsoluteSize.Y / 2 - 5.25
		),
		BackgroundColor3 = Color3.fromRGB(221, 215, 39),
		BorderSizePixel = 0,
		Text = "",

		[OnEvent("MouseButton1Down")] = function()
			self.DragStart:Fire({ 1, 1 })
		end,

		[OnEvent("MouseButton1Up")] = function()
			self.DragEnd:Fire()
		end,

		[Fusion.Children] = {
			YDragger = New("ImageButton")({
				Image = ICON_SET.drag_arrow,
				BackgroundTransparency = 1,
				ImageColor3 = Color3.fromHex("54CF49"),
				Parent = UserInterfaceSystem.UI,
				ZIndex = 99999991,
				Name = "YDragger",
				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.fromOffset(35, 150),
				Position = UDim2.fromScale(0.5, 0),

				[OnEvent("MouseButton1Down")] = function()
					self.DragStart:Fire({ 0, 1 })
				end,

				[OnEvent("MouseButton1Up")] = function()
					self.DragEnd:Fire()
				end,

				[OnEvent("MouseEnter")] = function()
					--self.YDragger.ImageColor3 = Color3.fromRGB(47, 136, 39)
					self.XYDragger.YDragger.ImageColor3 = Color3.fromRGB(
						84 - DARKENING_SELECTED_AMOUNT_THINGY,
						207 - DARKENING_SELECTED_AMOUNT_THINGY,
						73 - DARKENING_SELECTED_AMOUNT_THINGY
					)
				end,

				[OnEvent("MouseLeave")] = function()
					self.XYDragger.YDragger.ImageColor3 = Color3.fromRGB(84, 207, 73)
				end,
			}),

			XDragger = New("ImageButton")({
				Image = ICON_SET.drag_arrow,
				Rotation = 90,
				BackgroundTransparency = 1,
				ImageColor3 = Color3.fromRGB(207, 105, 73),
				Parent = UserInterfaceSystem.UI,
				ZIndex = 99999991,
				Name = "XDragger",
				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.fromOffset(35, 150),
				Position = UDim2.new(0, 90, 0.5, 75),

				[OnEvent("MouseButton1Down")] = function()
					self.DragStart:Fire({ 1, 0 })
				end,

				[OnEvent("MouseButton1Up")] = function()
					self.DragEnd:Fire()
				end,

				[OnEvent("MouseEnter")] = function()
					self.XYDragger.XDragger.ImageColor3 = Color3.fromRGB(
						207 - DARKENING_SELECTED_AMOUNT_THINGY,
						105 - DARKENING_SELECTED_AMOUNT_THINGY,
						73 - DARKENING_SELECTED_AMOUNT_THINGY
					)
				end,

				[OnEvent("MouseLeave")] = function()
					self.XYDragger.XDragger.ImageColor3 = Color3.fromRGB(207, 105, 73)
				end,
			}),
		},
	})

	self.Janitor:Add(self.XYDragger)

	return self
end

function DraggerBase:UpdatePos()
	self.XYDragger.Position = UDim2.fromOffset(
		self.Object.AbsolutePosition.X + self.Object.AbsoluteSize.X / 2 - 5.25,
		self.Object.AbsolutePosition.Y + self.Object.AbsoluteSize.Y / 2 - 5.25
	)
end

function DraggerBase:Destroy()
	self.Janitor:Cleanup()
end

return DraggerBase
