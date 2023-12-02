local Status = {}

local Gui = _G("classes.gui.Gui")
Gui:create("Status", Status)

function Status:__init(...)
	Gui.__init(self, ...)

	local instance = self.instance
	
	
end

return Status