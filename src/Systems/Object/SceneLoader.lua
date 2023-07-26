local Symbols = require(script.Parent.Symbols)

local SceneLoader = {}
SceneLoader.Compiler = {}

function SceneLoader.Compiler.MapSceneData<TBL>(sceneData: { TBL })
	local chunkObjects = {}
	local savedProperties = {}
	local objectType = nil

	local function ProcessAndMerge(object, saved, type, name)
		local objectData = {
			Properties = {},
			Symbols = {},
			ObjectType = type,
			ObjectClass = "Frame",
		}

		local function Process<TBL>(propertyTable: { TBL })
			local typeIndex, typeValue = Symbols.FindSymbol(propertyTable, "Type")

			if typeIndex then
				objectData.ObjectType = typeValue
			end

			if propertyTable then
				for propertyName, value in propertyTable do
					if Symbols.IsSymbol(propertyName) then
						objectData.Symbols[propertyName] = value

						continue
					end

					objectData.Properties[propertyName] = value
				end
			end
		end

		-- Order is very important
		Process(saved)
		Process(object)

		-- Re-allocate the Class property
		if objectData.Properties.Class then
			objectData.ObjectClass = objectData.Properties.Class
			objectData.Properties.Class = nil
		end

		-- Apply index as name if it is not present in the properties table
		if objectData.Properties.Name == nil then
			objectData.Properties.Name = name
		end

		return objectData
	end

	for _, sceneCategory in sceneData do
		if typeof(sceneCategory) ~= "table" then
			continue
		end

		-- Check if we can find a table with a [property] symbol attached
		-- As well as find the type of the category
		savedProperties = select(2, Symbols.FindSymbol(sceneCategory, "Property"))
		objectType = select(2, Symbols.FindSymbol(sceneCategory, "Type"))

		for objectName, object in sceneCategory do
			if Symbols.IsSymbol(objectName) then
				continue
			end

			table.insert(chunkObjects, ProcessAndMerge(object, savedProperties, objectType, objectName))
		end
	end

	return chunkObjects
end

function SceneLoader.Load(sceneData)
	print(SceneLoader.Compiler.MapSceneData(sceneData))
end

return SceneLoader
