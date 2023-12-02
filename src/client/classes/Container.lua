local Container = {}

local Replicator = _G("classes.Replicator")
Replicator:create("Container", Container)

local inventoryManager = _G("scripts.inventoryManager")

-- local Stack = _G("classes.Stack")

function Container:__init(name, capacity)
	assert(type(name) == "string", "Attempt to create Container with invalid name")
	assert(type(capacity) == "number", "Attempt to create Container with invalid capacity")

	Replicator.__init(self, name)

	self.name = name
	self.capacity = capacity
	self.stacks = {}

	self:onServer("updateItems", function(stacks)
		self.stacks = stacks
	end)

	self:onServer("associate", function(player)
		inventoryManager.associateInventory(self)
	end)
end

return Container