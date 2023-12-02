local Item = {}

local Object = _G("classes.Object")
local ItemTemplate = _G("templates.Item")
Object:create("Item", Item, ItemTemplate, "Item")

local playerData = _G("data.playerData")

local Notification = _G("classes.Notification")

function Item:__init(...)
	Object.__init(self, ...)

	self.displayName = self.displayName or self.id

	self:replicate()

	self:onClient("grab", function(player)
		local inventory = playerData[player].inventory

		assert(inventory, "Attempt to grab player item withought inventory")

		if not inventory:addItem(self) then
			if self.model then
				self:destroy()
			end
		else
			notification = Notification({
				title = "Inventory Full",
				text = "You cannot grab this item.",
				duration = 1,
			})
			notification:sendOnce(player)
		end
	end)
end

return Item