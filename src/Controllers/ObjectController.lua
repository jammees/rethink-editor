local Types = require(script.Parent.Utility.Types)
local Signal = require(script.Parent.Parent.Vendors.GoodSignal)
local DefaultProperties = require(script.Parent.Utility["DefaultProperties-v2"])
local Janitor = require(script.Parent.Parent.Library.Janitor)
local PluginFramework = require(script.Parent.Parent.Library.PluginFramework)

-- TEMP
local DumpParser = require(script.Parent.Parent.Library["dump-parser-0.1.1"])
local FetchDump = require(script.Parent.Parent.Library["dump-parser-0.1.1"].FetchDump)

local ObjectController = PluginFramework.CreateController("ObjectController")

function ObjectController:Init(display: PluginFramework.Display)
	self._Janitor = Janitor.new()

	self.Objects = {} :: { Types.ObjectData }
	self.ObjectAdded = Signal.new()

	local dumpData = self.Framework._Plugin:GetSetting("__rethink_property_dump") or {}
	local success, latestHashVersion = pcall(function()
		return FetchDump.fetchLatestVersionHash()
	end)

	display:CreateStatusLabel(latestHashVersion, Color3.fromRGB(184, 156, 3))

	if not success then
		display:CreateStatusLabel("Failed to fetch latest hash version, using saved API data!")

		latestHashVersion = dumpData.HashVersion
	end

	if dumpData.HashVersion ~= latestHashVersion then
		display:CreateStatusLabel("Saved API data is out-dated! Rebuilding...")

		dumpData.Dump = DumpParser.fetchRawDump(latestHashVersion)
		self.Framework._Plugin:SetSetting("__rethink_property_dump", dumpData)
	end

	self.Parser = DumpParser.new(dumpData.Dump)
end

function ObjectController:GetIndexFromObject(searchedObject)
	for index, object in self.Objects do
		if object.Object == searchedObject then
			return index
		end
	end

	error("Could not find object!")

	return -1
end

function ObjectController:CreateObject(class: string, kind: string, initProperties: { [string]: any })
	local UIController = self.Framework.GetController("UIController")

	local objectData = {
		Object = Instance.new(class),
		Class = class,
		Kind = kind,
		Properties = {},
	}

	for propertyName, value in DefaultProperties[class] do
		objectData.Object[propertyName] = value
	end

	for propertyName, value in initProperties do
		objectData.Object[propertyName] = value
		objectData.Properties[propertyName] = value
	end

	objectData.Object.Parent = UIController.Workspace

	if initProperties["Position"] == nil then
		objectData.Object.Position = UDim2.fromOffset(
			UIController.ClickDetector.AbsoluteSize.X / 2 - objectData.Object.AbsoluteSize.X / 2,
			UIController.ClickDetector.AbsoluteSize.Y / 2 - objectData.Object.AbsoluteSize.Y / 2
		)
		objectData.Properties["Position"] = objectData.Object.Position
	end

	local clickDetector = Instance.new("TextButton")
	clickDetector.BackgroundTransparency = 1
	clickDetector.Size = UDim2.fromScale(1, 1)
	clickDetector.Text = ""
	clickDetector.Name = "ClickDetector"
	clickDetector.Parent = objectData.Object

	self.ObjectAdded:Fire(objectData)

	self._Janitor:Add(objectData.Object)

	table.insert(self.Objects, objectData)

	return objectData
end

function ObjectController:GetPropertiesOf(kind: string)
	return self.Parser:GetProperties(kind)
end

function ObjectController:Start() end

function ObjectController:Stop()
	self._Janitor:Destroy()
	self.ObjectAdded:DisconnectAll()
	self.ObjectAdded = nil
end

return ObjectController
