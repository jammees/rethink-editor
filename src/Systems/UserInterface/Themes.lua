local FALLBACK_COLOR = Color3.fromRGB(161, 7, 189)
local BASE = {
	BG1 = 0,
	BG2 = 1,
	BG3 = 2,
	WorkspaceBG = 3,
	Dragger1 = 4,
	Dragger1Accent = 5,
	Dragger2 = 6,
	Dragger2Accent = 7,
	Dragger3 = 8,
	Dragger3Accent = 9,
	Highlight1 = 10,
	Text1 = 11,
	Text2 = 12,
	IconColor = 13,
}

type ThemeData = typeof(BASE)

local ConfigSystem = require(script.Parent.Parent.Config).Get()
local LoggerSystem = require(script.Parent.Parent.LoggerV1)

local Themes

local function CreateTheme(themeName, themeData): ThemeData
	local class = setmetatable(themeData, {
		__index = function(_, indexedItem)
			if not BASE[indexedItem] or not rawget(themeData, indexedItem) then
				LoggerSystem.Log(
					"Themes",
					3,
					`Attempted to index non-existing theme or theme entry ({themeName}.{indexedItem}); provided FALLBACK_COLOR`
				)

				return FALLBACK_COLOR
			end

			return rawget(themeData, indexedItem)
		end,
	})

	return class
end

Themes = {
	Dark = CreateTheme("Dark", {
		BG1 = Color3.fromHex("2C2C2C"),
		BG2 = Color3.fromHex("1D1D1D"),
		BG3 = Color3.fromHex("161616"),
		BG4 = Color3.fromHex("131313"),
		WorkspaceBG = Color3.fromHex("1D4BAD"),
		Dragger1 = Color3.fromHex("E15554"),
		Dragger1Accent = Color3.fromHex("8D3535"),
		Dragger2 = Color3.fromHex("3BB273"),
		Dragger2Accent = Color3.fromHex("256F48"),
		Dragger3 = Color3.fromHex("E1BC29"),
		Dragger3Accent = Color3.fromHex("8D761A"),
		Highlight1 = Color3.fromHex("161616"),
		Text1 = Color3.fromHex("FFFFFF"),
		Text2 = Color3.fromHex("C0C0C0"),
		IconColor = Color3.fromHex("FFFFFF"),
	}),

	Light = CreateTheme("Dark", {
		BG1 = Color3.fromRGB(255, 255, 255),
		BG2 = Color3.fromRGB(189, 189, 189),
		BG3 = Color3.fromRGB(152, 152, 152),
		BG4 = Color3.fromRGB(96, 96, 96),
		WorkspaceBG = Color3.fromHex("1D4BAD"),
		Dragger1 = Color3.fromHex("E15554"),
		Dragger1Accent = Color3.fromHex("8D3535"),
		Dragger2 = Color3.fromHex("3BB273"),
		Dragger2Accent = Color3.fromHex("256F48"),
		Dragger3 = Color3.fromHex("E1BC29"),
		Dragger3Accent = Color3.fromHex("8D761A"),
		Highlight1 = Color3.fromHex("161616"),
		Text1 = Color3.fromRGB(0, 0, 0),
		Text2 = Color3.fromRGB(46, 46, 46),
		IconColor = Color3.fromRGB(46, 46, 46),
	}),

	GetTheme = function(): ThemeData
		local ThemeData = Themes[ConfigSystem.ui_Theme:get()]

		if ThemeData then
			return ThemeData
		end

		return CreateTheme("Fallback Theme", {})
		--return Themes.Dark
	end,
}

return Themes
