local library = script.Parent.Parent.Library
local systems = script.Parent
local handlers = script.Handlers

local SelectorSystem = require(systems.Selector)
local ConfigSystem = require(systems.Config).Get()
local UserInterfaceSystem = require(systems.UserInterface)

local RenderAnchorPoint = require(handlers.manRenderAnchorPoint)
local Janitor = require(library.Janitor).new()

local mode = 0
local handlerModules = {
	require(handlers.manResize),
	require(handlers.manDrag),
}

local Manipulation = {}
Manipulation.ActiveHandler = nil

function Manipulation.Init()
	ConfigSystem.man_Mode:onChange(function(newValue)
		mode = newValue

		if Manipulation.ActiveHandler then
			Manipulation.ActiveHandler.Dismount()
			Manipulation.ActiveHandler = nil
		end

		if handlerModules[newValue] ~= nil then
			Manipulation.ActiveHandler = handlerModules[mode]
			Manipulation.ActiveHandler.Mount(SelectorSystem.Selected)
		end
	end)
end

function Manipulation.Start()
	Janitor:Add(UserInterfaceSystem.UI.Detector.MouseButton1Click:Connect(function()
		RenderAnchorPoint.Dismount()

		if Manipulation.ActiveHandler then
			Manipulation.ActiveHandler.Dismount()
			Manipulation.ActiveHandler = nil
		end
	end))

	Janitor:Add(SelectorSystem.Triggered:Connect(function(object: any)
		RenderAnchorPoint.Dismount()
		RenderAnchorPoint.Mount(object)

		if Manipulation.ActiveHandler then
			Manipulation.ActiveHandler.Dismount()
			Manipulation.ActiveHandler = nil
		end

		if handlerModules[mode] ~= nil then
			Manipulation.ActiveHandler = handlerModules[mode]
			Manipulation.ActiveHandler.Mount(object)
		end
	end))
end

function Manipulation.Destroy()
	Janitor:Cleanup()
end

return Manipulation
