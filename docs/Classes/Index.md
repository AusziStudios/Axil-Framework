[Go back to the main index](../index.md)

---

Classes are object-oriented objects. They have methods (functions which are called on specific instances of classes) and properties (data for specific instances of classes).

# Abstract Classes
Here are all of the pre-included classes. They exist in the project directly, and can be easily modified. They provide useful functionality, and  each inherit from the one before it.

When creating a new class, you can start from any of these, or none at all (if you wish you create your own class system).

1. [Class](Class.md)
is the pre-included base class for almost all objects.
1. [Emitter](Emitter.md) adds basic syncronous events.
2. [Replicator](Replicator.md) adds syncronous events to communicate accross the client-server boundary and replicates classes to clients.
3. [Template](Template.md) allows for creating sub-classes which inherit data from eachother. This is useful for things like a complex team system, with different variations for each team that are manually set and not random. ***UNDOCUMENTED***
4. [Object](Object.md) assigns a physical model to each template. ***UNDOCUMENTED***

# Example

Here is an example of a World object, inheriting from `Emitter`.
```lua
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
```

If the `World` class is located under `src/server/classes`, you can use it like this:

```lua
local worldManager = {}

local World = _G("classes.World")

-- Create a new instance/copy of World
-- You can also do World:new(...)
local world = World("Epic World", 50)

-- Receives an emitter event
world:on("generate", function(size)
	print("The world has been generated with a size of "..size)
end)

return worldManager
```