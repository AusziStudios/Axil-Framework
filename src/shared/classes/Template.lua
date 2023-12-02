-- An abstract class which inherits from Replicators. Is initalized with a table, conntaining information about all instances.

local Template = {}

local Replicator = _G("classes.Replicator")
Replicator:create("Template", Template)

local tools = _G("modules.tools")

local RunService = game:GetService("RunService")

local config = {
	UNINHERITED = {
		"id",
		"subClasses",
		"displayName",
		"formatted",
	}
}

local function formatRawItem(items, class)
	if not class then
		warn("Attempt to format raw item without class")
	end
	if not class.id then
		-- warn("Attempt to format raw item without ID", items, class)
		return
	end

	--Make a history for the items
	local classInheritance
	if not classInheritance then
		classInheritance = {}
	end
	table.insert(classInheritance, class.id)
	
	--Inherit any properties from parents
	local nextParent = class.parent
	while nextParent do
		for propertyName, propertyValue in pairs(nextParent) do
			if table.find(config.UNINHERITED, propertyName) then
				continue
			end
			if class[propertyName] ~= nil then
				continue
			end

			class[propertyName] = propertyValue
		end

		nextParent = nextParent.parent
	end

	local subClasses = class.subClasses or {}
	for subClassId, subClass in pairs(subClasses) do
		subClass.id = subClassId or subClass.id
		subClass.displayName = subClass.displayName or subClass.id
		subClass.parent = class
		subClass.inheritance = table.clone(classInheritance)

		formatRawItem(items, subClass)
	end

	items[class.id] = class
	return items
end

function Template:__create(items, itemClass)
	if type(items) ~= "table" then
		return
	end

	--Item class
	itemClass = itemClass or self.className
	self.itemClass = itemClass

	self.id = items.id
	self.templateItems = items

	--Format items
	-- if self.className == "Template" then -- PROBLEMS?
	-- 	return
	-- end

	items = formatRawItem({}, items)
	self.templateItems = items
end

function Template:__init(id)
	Replicator.__init(self, id)

	if not id then
		error("Attempt to initialize TemplateItem without an id")
		return
	end

	local items = self.templateItems
	local item = items[id]
	if not item then
		warn("No TemplateItem found")
		return
	end
	item = tools.deepCopy(item)

	for k, v in pairs(item) do
		if self[k] then
			continue
		end
		self[k] = v
	end
	self.id = id
	self.templateItem = item

	local update = self.update
	if update then
		RunService.Heartbeat:Connect(function(deltaTime)
			update(self, deltaTime)
		end)
	end

	return item
end

function Template:isA(anscestorId)
	local id = self.id

	assert(id, "Attempt to use isA on object with invalid id")

	local templateItems = Template.templateItems
	local templateItem = templateItems[id]

	assert(templateItem, "Attempt to use isA on object with no templateItem found")

	local parent = templateItem.parent
	while parent do
		local parentId = parent.id
		if parentId and parentId == anscestorId then
			return true
		end
	end

	return false
end

function Template:randomId(validate)
	local possible = {}
	for id, item in pairs(self.templateItems) do
		if validate then
			if not validate(item) then
				continue
			end
		end

		table.insert(possible, id)
	end

	if #possible <= 0 then
		return
	end
	local id = possible[math.random(1, #possible)]
	return id
end

function Template:turnInto(newId)
	error("Cannot use turnInto yet")
end

return Template