local library = script.Parent.Parent.Library
local systems = script.Parent
local handlers = script.Handlers

local SelectorSystem = require(systems.Selector)
local ConfigSystem = require(systems.Config)
local UserInterfaceSystem = require(systems.UserInterface)

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
		print(`Mode changed from {mode} to {newValue}`)
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
		if Manipulation.ActiveHandler then
			Manipulation.ActiveHandler.Dismount()
			Manipulation.ActiveHandler = nil
		end
	end))

	Janitor:Add(SelectorSystem.Triggered:Connect(function(object: any)
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
