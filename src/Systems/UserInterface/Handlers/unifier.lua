--[[
	unifier.lua

	An utility handler, which sole purpose is to set all the handlers' sizes to the
	same size for asthetics.
]]

-- Makes sure that all of the checkboxes have the same size
-- so it is more prettier to look at.

local Unifier = {}

function Unifier.unifiedXSize(props: { GuiBase2d })
	local biggestSize = 0

	for _, checkbox in ipairs(props) do
		if checkbox.Size.X.Offset > biggestSize then
			biggestSize = checkbox.Size.X.Offset
		end
	end

	for _, checkbox in ipairs(props) do
		checkbox.Size = UDim2.fromOffset(biggestSize, checkbox.Size.Y.Offset)
	end

	return Unifier
end

function Unifier.GetHandlerUIs(handlers: { any })
	local handlerUIs = {}

	for _, handler in handlers do
		table.insert(handlerUIs, handler:Get())
	end

	return handlerUIs
end

function Unifier.relativeSize(objects: { GuiBase2d }, container: GuiBase2d)
	local numberObjects = #objects
	local widhtRatio = 1 / numberObjects
	local paddingSize = container:FindFirstChildOfClass("UIListLayout").Padding.Offset or 0

	for index, object in objects do
		local applyPadding = index <= (numberObjects - 1)

		object.Size = UDim2.new(widhtRatio, applyPadding and -paddingSize or 0, 1, 0)
	end

	return Unifier
end

return Unifier
