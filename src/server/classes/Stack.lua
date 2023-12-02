local Stack = {}

local Replicator = _G("classes.Replicator")
Replicator:create("Stack", Stack)

function Stack:__init(item, container)
	Replicator.__init(self, item)

	assert(item, "Attempt to initialize stack without item")
	assert(item.id, "Attempt to initialize stack without item.id")
	assert(item.max, "Attempt to initialize stack without item.max")

	self.id = item.id
	self.displayName = item.displayName or item.id
	self.max = item.max
	self.items = {item}
	self.container = container

	self:replicate()

	self:call("addItem", item)
	self:call("updateItems", self.items)
	self:on("updateItems", function()
		if not container then
			return
		end
		container:call("updateItems", container.stacks)
	end)

	local function drop(player)
		local character = player.Character
		if not character then
			warn("Attempt to drop item withought character.")
			return
		end

		local lastItem = self.items[#self.items]
		if not lastItem then
			warn("No item found to drop!")
			return
		end
		self:removeItem(lastItem)

		local model = lastItem:getModel(workspace)
		local characterPivot = character:GetPivot()
		local cframe = characterPivot or CFrame.new()
		cframe = cframe * CFrame.new(math.random(15, 50) / 10, 0, 0)
		model:PivotTo(cframe)
	end

	self:onClient("dropOne", drop)
	self:onClient("dropAll", function(player)
		while #self.items > 0 do
			drop(player)
		end
	end)
end

function Stack:addItem(item)
	if self.id ~= item.id then
		return item
	end
	if self.max <= #self.items then
		return item
	end

	table.insert(self.items, item)

	self:call("addItem", item)
	self:call("updateItems", self.items)

	item.stack = self
	
	return nil
end

function Stack:addItems(items)
	local leftoverItems = {}

	for _, item in items do
		local leftoverItem = self:addItem(item)
		if leftoverItem then
			table.insert(leftoverItems, leftoverItem)
		end
	end

	return leftoverItems
end

function Stack:removeItem(item)
	local itemIndex = table.find(self.items, item)
	local container = self.container

	assert(itemIndex, "Attempt to removeItem without item present")

	item.stack = nil

	table.remove(self.items, itemIndex)

	if #self.items <= 0 and container then
		local stackIndex = table.find(container.stacks, self)
		if stackIndex then
			table.remove(container.stacks, stackIndex)
		end
	end

	self:call("removeItem", item)
	self:call("updateItems", self.items)

	return item
end

function Stack:removeItems(items)
	for _, item in items do
		self:removeItem(item)
	end

	return items
end

return Stack