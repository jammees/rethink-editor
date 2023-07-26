local library = script.Parent.Parent.Parent.Parent.Library
local systems = script.Parent.Parent.Parent
local pivots = script.Parent.Parent.Pivots

local MouseSystem = require(systems.Mouse)
local ObjectSystem = require(systems.Object)
local UserInterfaceSystem = require(systems.UserInterface)
local ConfigSystem = require(systems.Config).Get()

local Janitor = require(library.Janitor).new()

local Handler = {}

function Handler.Mount(object: Frame)
	if not ConfigSystem.man_ShowAnchorPoint:get() then
		return
	end

	local pos = object.AnchorPoint * object.AbsoluteSize

	local placeholder = Instance.new("Frame")
	placeholder.AnchorPoint = Vector2.new(0.5, 0.5)
	placeholder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	placeholder.BorderColor3 = Color3.fromRGB(255, 255, 255)
	placeholder.BorderSizePixel = 3
	placeholder.BackgroundTransparency = 0.5
	placeholder.Position = UDim2.fromOffset(pos.X, pos.Y)
	placeholder.Size = UDim2.fromOffset(12, 12)
	placeholder.Name = "AnchorPoint"
	placeholder.Parent = object

	Janitor:Add(object:GetPropertyChangedSignal("AnchorPoint"):Connect(function()
		Handler.Dismount()
		Handler.Mount(object)
	end))

	Janitor:Add(placeholder)
end

function Handler.Dismount()
	Janitor:Cleanup()
end

return Handler
