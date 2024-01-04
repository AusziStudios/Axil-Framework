-- An abstract class derivved from Emitter. Connects emitter across client-server boundary.

local Emitter = _G("classes.Emitter")
local Replicator = Emitter:create("Replicator")

local tools = _G("modules.tools")

local serializationModule = _G("modules.serializationModule")
local tools = _G("modules.tools")

local shared = _G("classes.Replicator.shared")
local cache = shared.cache
local replicatorRemotes = shared.replicatorRemotes

local replicatorListener = require(script:WaitForChild("listener"))

Replicator:inheritMultipleFrom({ replicatorListener })

-- TODO: DELETE?
-- local function findCachedTable(object)
-- 	if type(object) ~= "table" then
-- 		return
-- 	end

-- 	local replication = object["replication"]
-- 	if not replication then
-- 		return
-- 	end

-- 	local replicationId = replication["id"]
-- 	if not replicationId then
-- 		return
-- 	end

-- 	local cachedTable = cache[replicationId]
-- 	return cachedTable
-- end

-- local function replaceReplicated(replicatedClass)
-- 	for _, object in ipairs(tools.expandTable(replicatedClass)) do
-- 		for key, value in pairs(object) do
-- 			local newKey = findCachedTable(key)
-- 			local newValue = findCachedTable(value)

-- 			object[newKey or key] = newValue or value
-- 		end
-- 	end
-- end

local function onClientReplicate(replication, data) --TODO NEW FEATURE
	local replicationId = replication.id

	if cache[replicationId] then
		warn("Duplicate class cached on client")
		return
	end

	local className = replication.className
	local class = _G.require("classes." .. tostring(className))

	if not class then
		warn("Attempt to replicate class which could not be found", className)
		return
	end

	data = serializationModule.unserializeReplication(cache, data)

	local self = {}
	tools.inherit(class, self)

	local __replicate = self["__replicate"]
	if __replicate then
		__replicate(self, data)
	end

	cache[replicationId] = self

	replicatorRemotes:WaitForChild("replicate"):FireServer(replicationId)

	self:call("replicate")
end

local function onClientUnreplicate(replicationId)
	local self = cache[replicationId]

	if not self then
		return
	end

	self.replication = nil
	self:call("unreplicate")
end

replicatorRemotes:WaitForChild("replicate").OnClientEvent:Connect(onClientReplicate)
replicatorRemotes:WaitForChild("unreplicate").OnClientEvent:Connect(onClientUnreplicate)

function Replicator:getReplication()
	local replication = self.replication

	assert(replication, "Attempt to getReplication without replication")

	local replicationId = replication.id
	assert(replicationId, "Attempt to getReplication without replicationId")

	return replication
end

replicatorRemotes:WaitForChild("ready"):FireServer()

return Replicator
