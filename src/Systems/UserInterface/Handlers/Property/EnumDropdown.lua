-- Dropdown class that handles enums.
-- Extends Base\Dropdown.lua

--[[
	Vector3Field.lua

	A property handler, which accepts three numbers for X, Y and Z.
]]

type Props = {
	OnValueChange: (boolean) -> (),
	InitialValue: EnumItem,
	Priority: number,
	Object: GuiBase2d,
	Property: string,
	Janitor: any,
}

local library = script.Parent.Parent.Parent.Parent.Parent.Library

local ConfigSystem = require(script.Parent.Parent.Parent.Parent.Config).Get()

local DropdownBase = require(script.Parent.Parent.Base.Dropdown)
local NumberField = require(script.Parent.NumberField)
local Unifier = require(script.Parent.Parent.Unifier)

local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

local EnumDropdown = {}
EnumDropdown.__index = EnumDropdown

function EnumDropdown.new(props: Props)
	local self = setmetatable({}, EnumDropdown)

	self.Kind = "EnumDropdown"

	self.Props = props

	-- process the enums
	-- local enumTree =
	self.EnumTree = props.InitialValue.EnumType:GetEnumItems()
	self.EnumNames = {}

	for _, enumItem in self.EnumTree do
		table.insert(self.EnumNames, enumItem.Name)
	end

	self.DropdownHandler = DropdownBase.new({
		Name = props.Property,
		Elements = self.EnumNames,
		Janitor = props.Janitor,
		OnValueChange = function(element)
			for _, enumItem in self.EnumTree do
				if enumItem.Name == element then
					self.Props.OnValueChange(enumItem)

					return
				end
			end
		end,
	})

	return self
end

function EnumDropdown:CleanupIf(statement: boolean, connection: RBXScriptSignal | RBXScriptConnection)
	if statement then
		self.Props.Janitor:Add(connection)
	end
end

function EnumDropdown:Get()
	return self.DropdownHandler:GetUI()
end

return EnumDropdown
