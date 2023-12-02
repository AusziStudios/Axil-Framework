local Replicator = {}

local Emitter = _G("classes.Emitter")
Emitter:create("Replicator", Replicator)

local replicatorReplication = require(script:WaitForChild("replication"))
local replicatorListener = require(script:WaitForChild("listener"))
local replicatorOwnership = require(script:WaitForChild("ownership"))

Emitter.inherit(Replicator, replicatorReplication, replicatorListener, replicatorOwnership)

return Replicator