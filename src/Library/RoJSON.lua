-- A JSON parser, which supports the encoding and decoding of roRoJSON types (e.g. Enum, Vector2, UDim2)
-- Does not account for mixed table types!
-- Version: 0.1
type DictionaryOrArray = { [string | number]: any }
type JSON = string

type Methods = {
	Encode: (tbl: DictionaryOrArray) -> JSON,
	Decode: (jsonData: JSON) -> DictionaryOrArray,
}

local HTTPService = game:GetService("HttpService")

local PREFIX = "~"
local SEPARATOR = "‌" -- No-widht character U+200c
local CLASS_TYPES = {
	vec2 = 1,
	vec3 = 2,
	enum_item = 3,
	udim = 4,
	udim2 = 5,
}

local function IsDictionary<T>(tbl: { T })
	return rawlen(tbl) == 0
end

local function EncodeValue(value: any, RoJSON: Methods): string
	if typeof(value) == "string" then
		return `"{value}"`
	end

	if typeof(value) == "table" then
		return RoJSON.Encode(value)
	end

	if typeof(value) == "Vector2" then
		local v: Vector2 = value
		return `"{PREFIX}{CLASS_TYPES.vec2}{v.X}{SEPARATOR}{v.Y}"`
	end

	if typeof(value) == "Vector3" then
		local v: Vector3 = value
		return `"{PREFIX}{CLASS_TYPES.vec3}{v.X}{SEPARATOR}{v.Y}{SEPARATOR}{v.Z}"`
	end

	if typeof(value) == "nil" then
		return "null"
	end

	if typeof(value) == "boolean" then
		return tostring(value)
	end

	if typeof(value) == "number" then
		return tostring(value)
	end

	if typeof(value) == "EnumItem" then
		local v: EnumItem = value
		return `"{PREFIX}{CLASS_TYPES.enum_item}{v.EnumType}{SEPARATOR}{v.Name}"`
	end

	if typeof(value) == "UDim" then
		local v: UDim = value
		return `"{PREFIX}{CLASS_TYPES.udim}{v.Scale}{SEPARATOR}{v.Offset}"`
	end

	if typeof(value) == "UDim2" then
		local v: UDim2 = value
		return `"{PREFIX}{CLASS_TYPES.udim2}{v.X.Scale}{SEPARATOR}{v.X.Offset}{SEPARATOR}{v.Y.Scale}{SEPARATOR}{v.Y.Offset}"`
	end

	error(`Attemped to encode unknown value of "{tostring(value)}" type {typeof(value)}!`)
end

local function DecodeValue(value: any)
	local function ToNumTuple<T>(tuple: { T })
		local converted = {}

		for index, val in tuple do
			converted[index] = tonumber(val)
		end

		return converted
	end

	if typeof(value) == "string" and string.sub(value, 1, 1) == PREFIX then
		local kind = tonumber(string.sub(value, 2, 2))
		local arguments = string.split(string.sub(value, 3, -1), SEPARATOR)

		if kind == 1 then
			return Vector2.new(table.unpack(ToNumTuple(arguments)))
		end

		if kind == 2 then
			return Vector3.new(table.unpack(ToNumTuple(arguments)))
		end

		if kind == 3 then
			return Enum[arguments[1]][arguments[2]]
		end

		if kind == 4 then
			return UDim.new(table.unpack(ToNumTuple(arguments)))
		end

		if kind == 5 then
			return UDim2.new(table.unpack(ToNumTuple(arguments)))
		end

		error(`Attempted to parse prefixed value, however no such type was found!`)
	end

	return value
end

local RoJSON = {}

--[=[
	Encodes the given table into a JSON format including the
	supported constructors and values.

	**Supported values are**:
	- string
	- table
	- vector2
	- vector3
	- nil
	- boolean
	- number
	- enumitem
	- UDim
	- UDim2

	**Example**:
	```lua
	local RoJSON = require(PATH_TO_MODULE)

	local example = {
		{
			string = "Hello world!",
			number = 101,
			nested_tbl = {
				{ "Hello" },
				{ "World" },
			},
			supported_types = {
				vec2 = Vector2.new(26, 363),
				vec3 = Vector3.new(0, 5, 0),
				enum_item = Enum.Font.Arcade,
				udim2 = UDim2.new(1, 500, 1, 500),
				udim = UDim.new(101, 101),
			},
		},
	}

	local json = RoJSON.Encode(example)

	print(json)
	```
]=]
---@param tbl table
---@return string
function RoJSON.Encode(tbl: DictionaryOrArray): JSON
	local isDictionary = IsDictionary(tbl)
	local parsedData = ""

	for index, value in tbl do
		if parsedData ~= "" then
			parsedData ..= ","
		end

		local idx = isDictionary and `"{tostring(index)}":` or ``
		local val = EncodeValue(value, RoJSON)

		parsedData ..= `{idx}{val}`
	end

	return string.format(isDictionary and "{%s}" or "[%s]", parsedData)
end

--[=[
	Decodes the given JSON string into a table, whilst reconverting supported
	constructors and values.

	**Example**:
	```lua
	local RoJSON = require(PATH_TO_MODULE)

	local example = {
		{
			string = "Hello world!",
			number = 101,
			nested_tbl = {
				{ "Hello" },
				{ "World" },
			},
			supported_types = {
				vec2 = Vector2.new(26, 363),
				vec3 = Vector3.new(0, 5, 0),
				enum_item = Enum.Font.Arcade,
				udim2 = UDim2.new(1, 500, 1, 500),
				udim = UDim.new(101, 101),
			},
		},
	}

	local json = RoJSON.Encode(example)
	local decodedJson = RoJSON.Decode(json)

	print(json)
	print(decodedJson)
	```
]=]
---@param jsonData string
---@return table
function RoJSON.Decode(jsonData: JSON): DictionaryOrArray
	local jsonTbl = {}

	local function Parse<T, P>(tbl: { T }, parentTbl: { P })
		for index, value in tbl do
			if typeof(value) == "table" then
				parentTbl[index] = {}
				Parse(value, parentTbl[index])
				continue
			end

			parentTbl[index] = DecodeValue(value)
		end
	end

	Parse(HTTPService:JSONDecode(jsonData), jsonTbl)

	return jsonTbl
end

export type RoJSON = Methods

return RoJSON
