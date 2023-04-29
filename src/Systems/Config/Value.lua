local Value = {}
Value.__index = Value

function Value.new(defaultValue: any)
	local self = setmetatable({}, Value)
	self._callbacks = {}
	self._value = defaultValue
	return self
end

function Value:onChange(callback)
	table.insert(self._callbacks, callback)
end

function Value:get()
	return self._value
end

function Value:set(newValue)
	if self._value ~= newValue then
		self._value = newValue

		for _, callback in ipairs(self._callbacks) do
			callback(newValue)
		end
	end
end

return Value
