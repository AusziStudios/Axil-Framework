local windowManager = {}

local Sidebar = _G("classes.gui.Sidebar")

local inventoryManager = _G("scripts.inventoryManager")
local inventoryWindow = inventoryManager.window

local mainSidebar = Sidebar("Sidebar")

mainSidebar:addButton("Inventory", function()
	inventoryWindow:open()
end)

mainSidebar:addButton("health", function()
	
end)

mainSidebar:addButton("LOCKED", function()
	
end)

local function close()
	mainSidebar:unselect()
end

inventoryWindow:on("close", close)

mainSidebar:open()

return windowManager