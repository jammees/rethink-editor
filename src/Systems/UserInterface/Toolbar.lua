local toolbarHandlers = script.Parent.Handlers.Toolbar
local library = script.Parent.Parent.Parent.Library
local handlers = script.Parent.Handlers

local ConfigSystem = require(script.Parent.Parent.Config)

local H_toolbarCategory = require(toolbarHandlers.ToolbarCategory)
local H_toolbarButton = require(toolbarHandlers.ToolbarButton)
local H_numberField = require(handlers.Property.NumberField)
local H_checkbox = require(handlers.Property.Checkbox)
local H_unifier = require(handlers.Unifier)

local ICON_SET = require(script.Parent.ICON_SET)
local Fusion = require(library.Fusion)
local Children = Fusion.Children
local New = Fusion.New

return function()
	local container = nil

	container = New("Frame")({
		Name = "Toolbar",
		Size = UDim2.new(1, 0, 0, 100),
		Position = UDim2.fromOffset(0, 30),
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),

		[Children] = {
			List = New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 5),
			}),

			Padding = New("UIPadding")({
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
			}),

			H_toolbarCategory({
				Separator = "right",
				Title = "Object Manipulation",

				Handlers = {
					H_toolbarButton({
						Title = "Drag",
						IconIDX = ICON_SET.move,
						Priority = 1,
						OnClick = function()
							if ConfigSystem.man_Mode:get() == 2 then
								ConfigSystem.man_Mode:set(0)
							else
								ConfigSystem.man_Mode:set(2)
							end
						end,
					}),

					H_toolbarButton({
						Title = "Resize",
						IconIDX = ICON_SET.resize,
						Priority = 2,
						OnClick = function()
							if ConfigSystem.man_Mode:get() == 1 then
								ConfigSystem.man_Mode:set(0)
							else
								ConfigSystem.man_Mode:set(1)
							end
						end,
					}),

					H_toolbarCategory({
						Direction = Enum.FillDirection.Vertical,
						Priority = 3,
						Handlers = {
							H_unifier({
								Checkboxes = {
									H_checkbox.new({
										Title = "Snap to Grid",
										InitialValue = false,
										OnValueChange = function(newState: boolean)
											ConfigSystem.man_SnapToGrid:set(newState)
										end,
									}):Get(),

									H_numberField.new({
										Range = NumberRange.new(0, math.huge),
										InitialValue = ConfigSystem.man_GridSize:get(),
										OnValueChange = function(newValue)
											ConfigSystem.man_GridSize:set(newValue)
										end,
									}):Get(),
								},

								Modifiers = {
									unifiedXSize = true,
								},
							}),
						},
					}),
				},
			}),

			--[[ H_toolbarButton({
				Title = "Get export data from",
				OnClick = function()
					local ObjectSys = require(script.Parent.Parent.Object)
					local SelectorSys = require(script.Parent.Parent.Selector)

					print(ObjectSys.GetFromObject(SelectorSys.Selected).ExportData)
				end,
			}),

			-- Oh no
			-- bad code
			-- very bad code
			-- that works somehow
			-- dont ask me how
			H_toolbarButton({
				Title = "Export default properties",
				OnClick = function()
					local DumpParser = require(library["dump-parser-0.1.1"])
					local dump = DumpParser.fetchFromServer()
					local filter = dump.Filter

					local objectsToScan: Folder = game:GetService("Lighting").ObjectsToScan

					local exportedData = {}
					local handlerTypes = {}

					for _, obj in objectsToScan:GetChildren() do
						local props = dump:GetProperties(obj, filter.Invert(filter.ReadOnly))

						exportedData[obj.ClassName] = props
					end

					print(exportedData)

					local module = Instance.new("ModuleScript")
					module.Name = "Default Properties"
					module.Parent = game.Lighting

					local moduleSource = "--Exported default UI properties using DumpParser\n\nreturn {"

					for class, props in exportedData do
						moduleSource = moduleSource .. ("\n\t%s = {"):format(class)

						for
							propName,
							data: {
							MemberType: "Property",
							Category: string,
							Name: string,
							Security: {
								Read: string,
								Write: string,
							},
							Serialization: {
								CanLoad: boolean,
								CanSave: boolean,
							},
							Tags: { string }?,
							ThreadSafety: string,
							ValueType: {
								Category: string,
								Name: string,
							},
						}
						in props do
							if propName == "Parent" then
								continue
							end

							if table.find(handlerTypes, data.ValueType.Name) == nil then
								table.insert(handlerTypes, data.ValueType.Name)
							end

							local objProperty = objectsToScan:FindFirstChildOfClass(class)[propName]
							local serialized = nil

							if typeof(objProperty) == "string" then
								serialized = `\"{objProperty}\"`
							elseif typeof(objProperty) == "UDim2" then
								local udim2: UDim2 = objProperty
								serialized =
									`UDim2.new({udim2.X.Scale}, {udim2.X.Offset}, {udim2.Y.Scale}, {udim2.Y.Offset})`
							elseif typeof(objProperty) == "Color3" then
								serialized = `Color3.new({objProperty})`
							elseif typeof(objProperty) == "number" or typeof(objProperty) == "boolean" then
								serialized = tostring(objProperty)
							elseif typeof(objProperty) == "Vector2" then
								serialized = `Vector2.new({objProperty})`
							elseif typeof(objProperty) == "Font" then
								local font: Font = objProperty
								serialized = `Font.new("{font.Family}", {font.Weight}, {font.Style})`
							elseif typeof(objProperty) == "EnumItem" then
								serialized = tostring(objProperty)
							elseif typeof(objProperty) == "nil" then
								serialized = "nil"
							elseif typeof(objProperty) == "Rect" then
								local rect: Rect = objProperty
								serialized =
									`Rect.new(Vector2.new({rect.Min.X}, {rect.Min.Y}), Vector2.new({rect.Max.X}, {rect.Max.Y}))`
							elseif typeof(objProperty) == "Vector3" then
								local vec3: Vector3 = objProperty
								serialized = `Vector3.new({vec3.X}, {vec3.Y}, {vec3.Z})`
							else
								warn(`{propName} = {typeof(objProperty)} for {class} not processed!`)
							end

							moduleSource = moduleSource .. ("\n\t\t%s = %s,"):format(propName, serialized)
						end

						moduleSource = moduleSource .. "\n\t},"
					end

					moduleSource = moduleSource .. "\n}"

					module.Source = moduleSource

					print(handlerTypes)
				end,
			}), ]]
		},
	})

	return container
end
