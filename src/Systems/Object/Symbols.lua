type Rigidbody = { [string]: any }

type AvailableSymbols = {
	Property: any,
	Type: any,
	Tag: any,
	Rigidbody: any,
	Event: (propertyName: string) -> Instance | Rigidbody,
	ShouldFlush: any,
}

local Symbols = {}

-- If callback is not provided, it will return the symbol and it's value
-- Does not account for multiple symbols being the same type in the same table.
-- Won't fix most likely, since why would you do that?
function Symbols.FindSymbol(array: { any }, targetSymbol: string)
	if typeof(array) ~= "table" then
		return
	end

	for index, value in pairs(array) do
		if typeof(index) == "table" and index.Type == "Symbol" then
			if index.Name == targetSymbol then
				return index, value
			end
		end
	end

	return nil
end

function Symbols.IsSymbol(tableIndex: any): boolean
	if typeof(tableIndex) == "table" and tableIndex.Name ~= nil then
		return true
	end

	return false
end

return Symbols
