local inventoryManager = {}

local Window = _G("classes.gui.Window")
local Slot = _G("classes.gui.Slot")

local window = Window("Inventory", _G.gui.Secondary)
local content = window.instance:WaitForChild("Content")
local scrollingFrame = content:WaitForChild("ScrollingFrame")
scrollingFrame.Visible = true

local inventory = nil

local slots = {}

local function refresh()
	if not inventory then
		warn("Attempt to refresh inventory with no associated inventory")
		return
	end

	for _, slot in ipairs(slots) do
		slot.instance:Destroy()
	end
	table.clear(slots)

	for _, stack in pairs(inventory.stacks) do
		local slot = Slot(stack.id or "ERROR", scrollingFrame)
		local slotContent = slot.instance:WaitForChild("Content")
		local slotLabel = slotContent:WaitForChild("Label")
		local slotViewport = slotContent:WaitForChild("Viewport")

		local firstItem = stack.items[1]

		slotLabel.Text = stack.id

		if firstItem then
			local model = firstItem:getBaseModel()
			if model then
				model = model:Clone()
				model:PivotTo(CFrame.new())
				model.Parent = slotViewport

				local slotCamera = slotViewport:WaitForChild("Camera")
				local size = model:GetExtentsSize()

				local position = Vector3.new(size.X / 2 + 0.25, size.Y / 2 + 0.5, size.Z / 2 + 0.25)
				slotCamera.Focus = CFrame.new()
				slotCamera.CFrame = CFrame.new(position, Vector3.zero)
			else
				warn("Missing baseModel")
			end
		else
			warn("Missing firstItem")
		end

		slot.instance.MouseButton1Up:Connect(function()
			stack:call("dropOne")
		end)
		slot.instance.MouseButton2Up:Connect(function()
			stack:call("dropAll")
		end)

		table.insert(slots, slot)
	end
end

function inventoryManager.associateInventory(newInventory)
	inventory = newInventory
	inventory:onServer("updateItems", refresh)
end

window:on("open", refresh)

inventoryManager.window = window
return inventoryManager
