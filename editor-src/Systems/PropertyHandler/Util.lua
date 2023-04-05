local Config = {
	Range = {
		Color3 = NumberRange.new(0, 255),
		Transparency = NumberRange.new(0, 1),
	},
}

local PropertyConfig = {}

function PropertyConfig.GetRangeFromProperty(property: string): NumberRange
	for propertyName, range in Config.Range do
		if property:find(propertyName) then
			return range
		end
	end
end

return PropertyConfig
