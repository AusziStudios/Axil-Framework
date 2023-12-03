-- Initialize the resourceModule
require(game:GetService("ReplicatedStorage"):WaitForChild("modules"):WaitForChild("resourceModule"))

-- Do other stuff here, such as requiring other scripts.
-- _G("scripts.somethingManager")


-- # EXAMPLE FROM DOCUMENTATION #

-- Initialize the Replicator
_G("classes.Replicator")

local World = _G("classes.World")

-- Create a new instance/copy of World
-- You can also do World:new(...)
local world = World("Epic World", 50)

-- Receives an emitter event
world:on("generate", function(size)
	print("The world has been generated with a size of "..size)
end)

world:generate()