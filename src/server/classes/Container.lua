local Container = {}

local Replicator = _G("classes.Replicator")
Replicator:create("Container", Container)

local Stack = _G("classes.Stack")

function Container:__init(name, capacity)
	assert(type(name) == "string", "Attempt to create Container with invalid name")
	assert(type(capacity) == "number", "Attempt to create Container with invalid capacity")

	Replicator.__init(self, name, capacity)

	self.name = name
	self.capacity = capacity
	self.stacks = {}

	self:replicate()
end

function Container:addItem(item)
	for slotNumber = 1, self.capacity do
		local existingStack = self.stacks[slotNumber]
		if existingStack then
			local leftoverItem = existingStack:addItem(item)
			if not leftoverItem then -- If there's no leftover item, return
				self:call("addItem", item)
				self:call("updateItems", self.stacks)
				return
			end
		else
			self.stacks[slotNumber] = Stack(item, self)
			return
		end
	end

	return item
end

function Container:addItems(items)
	local leftoverItems = {}

	for _, item in items do
		local leftoverItem = self:addItem(item)
		if leftoverItem then
			table.insert(leftoverItems, leftoverItem)
		end
	end

	return leftoverItems
end

function Container:removeItem(item)
	for _, stack in self.stacks do
		if not table.find(stack.items, item) then
			continue
		end

		self:call("removeItem", item)
		self:call("updateItems", self.stacks)
		return stack:removeItem(item)
	end

	error("Attempt to remove item from container that wasn't present")
end

function Container:removeItems(items)
	for _, item in items do
		self:removeItem(item)
	end

	return items
end

return Container