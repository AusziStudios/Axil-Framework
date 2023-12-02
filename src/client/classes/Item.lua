local Item = {}

local Object = _G("classes.Object")
local ItemTemplate = _G("templates.Item")
Object:create("Item", Item, ItemTemplate, "Item")

function Item:__init(...)
	Object.__init(self, ...)

	self.displayName = self.displayName or self.id

	self:onServer("newModel", function(model)
		local primaryPart = self:waitForPrimaryPart()

		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.ObjectText = self.displayName
		proximityPrompt.ActionText = "Grab"

		proximityPrompt.Triggered:Connect(function()
			self:call("grab")
		end)

		proximityPrompt.Parent = primaryPart
	end)
end

return Item