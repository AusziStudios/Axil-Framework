local Stack = {}

local Replicator = _G("classes.Replicator")
Replicator:create("Stack", Stack)

function Stack:__init(item)
	Replicator.__init(self, item)

	item.max = item.max or 1

	assert(item, "Attempt to initialize stack without item")
	assert(item.id, "Attempt to initialize stack without item.id")
	assert(item.max, "Attempt to initialize stack without item.max")

	self.id = item.id
	self.displayName = item.displayName or item.id
	self.max = item.max
	self.items = {item}

	local function updateItems(items)
		print(items)
	end

	self:on("addItem", updateItems)
	self:on("removeItem", updateItems)
end

return Stack