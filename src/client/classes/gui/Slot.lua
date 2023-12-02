local Slot = {}

local Gui = _G("classes.gui.Gui")
Gui:create("Slot", Slot)

function Slot:__init(...)
	Gui.__init(self, ...)

	local instance = self.instance
	local content = instance:FindFirstChild("Content")
	local viewport = content:FindFirstChild("Viewport")
	local camera = viewport:FindFirstChild("Camera")
	viewport.CurrentCamera = camera
end

return Slot