local listener = {}

local shared = _G("classes.Replicator.shared")
local cache = shared.cache
local replicatorRemotes = shared.replicatorRemotes

local serializationModule = _G("modules.serializationModule")

-- Find events
function listener:establish(eventName)
	local replication = self.replication
	assert(replication, "Attempt to establish without replication")

	local remotes = replication.remotes
	assert(remotes, "Attempt to establish without remotes")

	local specificRemote = remotes[eventName]
	assert(specificRemote, "Attempt to establish without event " .. tostring(eventName))
	
	return specificRemote
end

-- Call events
function listener:callServer(eventName, ...)
	assert(type(eventName) == "string", "Attempt to callServer with invalid eventName")

	local replication = self.replication
	local replicationId = replication.id

	local remote = self:establish(eventName)

	local vararg = serializationModule.serializeReplication({...})

	remote:FireServer(replicationId, vararg)

	self:call("callServer", eventName, ...)
end

-- On events
function listener:onClient(eventName, callback)
	local replicationCallbacks = self.replicationCallbacks or {}
	local eventCallbacks = replicationCallbacks[eventName] or {}
	
	table.insert(eventCallbacks, callback)

	replicationCallbacks[eventName] = eventCallbacks
	self.replicationCallbacks = replicationCallbacks

	self:call("bindClient", eventName, callback)
end

replicatorRemotes:WaitForChild("establish").OnClientEvent:Connect(function(establishedRemotes)
	for _, remote in ipairs(establishedRemotes) do
		remote.OnClientEvent:Connect(function(replicationId, vararg)
			local self = cache[replicationId]
			assert(self, "Attempt to receive onClient remote without cached class")

			vararg = serializationModule.unserializeReplication(vararg) or {}

			local eventName = remote.Name

			local replicationCallbacks = self.replicationCallbacks or {}
			local eventCallbacks = replicationCallbacks[eventName] or {}

			for _, callback in ipairs(eventCallbacks) do
				local success, returned = pcall(function()
					callback(table.unpack(vararg))
				end)
				assert(success, "Error when running onClient callback on " .. tostring(replicationId) .. ":\n" .. tostring(returned))
			end

			self:call("onClient", eventName, table.unpack(vararg))
		end)
	end
end)

-- Hook events
function listener:hook(eventName, defaultValues)
	self:onClient(eventName, function(...)
		self:call(eventName, ...)
	end)

	for _, defaultValue in ipairs(defaultValues or {}) do
		self:call(eventName, defaultValue)
	end
end

return listener