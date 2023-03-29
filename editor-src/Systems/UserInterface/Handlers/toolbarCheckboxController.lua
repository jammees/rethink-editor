-- Makes sure that all of the checkboxes have the same size
-- so it is more prettier to look at.

type Props = {
	Checkboxes: { any },
	Modifiers: { unifiedXSize: boolean, relativeSize: boolean },
}

return function(props: Props)
	if props.Modifiers.unifiedXSize then
		local biggestSize = 0

		for _, checkbox in ipairs(props.Checkboxes) do
			if checkbox.Size.X.Offset > biggestSize then
				biggestSize = checkbox.Size.X.Offset
			end
		end

		for _, checkbox in ipairs(props.Checkboxes) do
			checkbox.Size = UDim2.fromOffset(biggestSize, checkbox.Size.Y.Offset)
		end
	end

	--[[ if props.Modifiers.relativeSize then
		for _, checkbox in ipairs(props.Checkboxes) do
			checkbox.Size = UDim2.fromOffset(checkbox.Size.X.Offset, checkbox.Size.Y.Offset / #props.Checkboxes)
		end
	end ]]

	return table.unpack(props.Checkboxes)
end
