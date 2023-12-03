local World = {}

-- Get the Emitter class
local Emitter = _G("classes.Emitter")

-- Create the class, inheriting from Emitter
Emitter:create("World", World)

-- Fetch services, modules, and other classes
local terrain = workspace.Terrain

-- Default properties
World.worldName = "Default World"
World.terrainSize = 0
World.isGenerated = false

function World:__init(worldName, terrainSize, ...)
	-- Because it's being overwritten,
	-- you need to call this to inherit it's behavior
	Emitter.__init(self, worldName, terrainSize, ...)
        -- FYI: Emitter doesn't contain anything important in the __init unless you are going to use replication

	-- You can update properties here
	self.worldName = worldName
	self.terrainSize = terrainSize
end

function World:generate()
	local length = self.terrainSize / 2

	terrain:FillBlock(
		CFrame.new(),
		Vector3.new(length, 5, length),
		Enum.Material.Grass
	)

	self.isGenerated = true -- Update a property
	self:call("generate", self.terrainSize) -- Calls an Emitter event
end

function World:clear()
	terrain:Clear()
	self.isGenerated = false
	self:call("clear") -- Calls an Emitter event
end

return World