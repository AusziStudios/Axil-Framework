-- An abstract class derivved from Emitter. Connects emitter across client-server boundary.

local Replicator = {}

local Emitter = _G("classes.Emitter")
Emitter:create("Replicator", Replicator)

local tools = _G("modules.tools")

local serializationModule = _G("modules.serializationModule")

local shared = _G("classes.Replicator.shared")
local cache = shared.cache
local replicatorRemotes = shared.replicatorRemotes

local replicatorListener = require(script:WaitForChild("listener"))

Emitter.inherit(Replicator, replicatorListener)

local function findCachedTable(object)
    if type(object) ~= "table" then
        return
    end

    local replication = object["replication"]
    if not replication then
        return
    end

    local replicationId = replication["id"]
    if not replicationId then
        return
    end

    local cachedTable = cache[replicationId]
    return cachedTable
end

local function replaceReplicated(replicatedClass)
    for _, object in ipairs(tools.expandTable(replicatedClass)) do
        for key, value in pairs(object) do
            local newKey = findCachedTable(key)
            local newValue = findCachedTable(value)
            
            object[newKey or key] = newValue or value
        end
    end
end

local function onClientReplicate(replicatedClass)
    replicatedClass = serializationModule.unserializeCyclic(replicatedClass)

    local className = replicatedClass.className
    local class = _G("classes."..tostring(className))

    if not class then
        warn("Attempt to replicate class which could not be found", className)
        return
    end

    replaceReplicated(replicatedClass)

    local initParams = replicatedClass.initParams or {}
    local replicationId = replicatedClass.replication.id

    if cache[replicationId] then
        warn("Duplicate class cached on client")
        return
    end
    local self = class:newFromTemplate(replicatedClass, table.unpack(initParams))
    cache[replicationId] = self

    self:call("replicate")

    replicatorRemotes:WaitForChild("replicate"):FireServer(replicationId)
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

return Replicator