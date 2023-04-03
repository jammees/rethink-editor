local library = script.Parent.Parent.Parent.Library
local handlers = script.Parent.Handlers

local ConfigSystem = require(script.Parent.Parent.Config)

local H_createToolbarButtonBig = require(handlers.createToolbarButtonBig)
local H_createToolbarCategory = require(handlers.createToolbarCategory)
local H_createToolbarCheckbox = require(handlers.createToolbarCheckbox)
local H_toolbarCheckboxController = require(handlers.toolbarCheckboxController)
local H_createToolbarNumberField = require(handlers.createToolbarNumberField)

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

			H_createToolbarCategory({
				Separator = "right",
				Title = "Object Manipulation",

				Handlers = {
					H_createToolbarButtonBig({
						Title = "Drag",
						IconIDX = 8,
						Priority = 1,
						OnClick = function()
							if ConfigSystem.man_Mode:get() == 2 then
								ConfigSystem.man_Mode:set(0)
							else
								ConfigSystem.man_Mode:set(2)
							end
						end,
					}),

					H_createToolbarButtonBig({
						Title = "Resize",
						IconIDX = 7,
						Priority = 2,
						OnClick = function()
							if ConfigSystem.man_Mode:get() == 1 then
								ConfigSystem.man_Mode:set(0)
							else
								ConfigSystem.man_Mode:set(1)
							end
						end,
					}),

					H_createToolbarCategory({
						Direction = Enum.FillDirection.Vertical,
						Priority = 3,
						Handlers = {
							H_toolbarCheckboxController({
								Checkboxes = {
									H_createToolbarCheckbox({
										Title = "Snap to Grid",
										InitialState = false,
										OnStateChange = function(newState: boolean)
											ConfigSystem.man_SnapToGrid:set(newState)
										end,
									}),

									H_createToolbarNumberField({
										InitialValue = ConfigSystem.man_GridSize:get(),
										OnValueChange = function(newValue)
											ConfigSystem.man_GridSize:set(newValue)
										end,
									}),
								},

								Modifiers = {
									unifiedXSize = true,
									--relativeSize = true,
								},
							}),
						},
					}),
				},
			}),
		},
	})

	return container
end
