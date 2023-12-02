-- An abstract class derivved from Emitter. Connects emitter across client-server boundary.

local replication = {}

local serializationModule = _G("modules.serializationModule")

local shared = _G("classes.Replicator.shared")
local cache = shared.cache
local remotes = shared.remotes
local replicatorRemotes = shared.replicatorRemotes

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Emitter = _G("classes.Emitter")

local config = _G("config.Replicator")

function replication:__init(...)
	Emitter.__init(self, ...)

	self.initParams = { ... }
	self.replication = nil
end

local function replicateToClient(self, client)
	local replication = self:getReplication(client)

	assert(replication, "Attempt to replicateToClient without replication")

	local replicationId = replication.id

	local clientReplication = {
		remotes = replication.remotes,
		id = replicationId,
	}

	local serializedSelf = table.clone(self)
	serializedSelf.replication = clientReplication
	serializedSelf = self:__serialize(serializedSelf)

	local received = false
	local connection = replicatorRemotes.replicate.OnServerEvent:Connect(function(otherClient, otherReplicationId)
		if client ~= otherClient or replicationId ~= otherReplicationId then
			return
		end

		received = true
	end)

	-- TODO avoid reliance on looping and waiting:
	-- mabye cache things on the server the client needs to get once they join,
	-- and send them once the client say's it's ready
	for i = 1, 3 do 
		replicatorRemotes.replicate:FireClient(client, serializedSelf)

		if received then
			break
		end
		task.wait(1)
	end
	if not received then
		warn("Failed to replicate object to client " .. tostring(client.Name))
		client:Kick("Failed to replicate object to client.")
	end

	self:call("clientAdded", client)
	connection:Disconnect()
end

function replication:replicate(clients)
	assert(false, "CANNOT REP")
	assert(not self.replication, "Attempt to replicate an already-replicated class")

	local className = self.className

	-- Create a unique replicationId
	local replicationId
	repeat
		replicationId = HttpService:GenerateGUID(false)
	until not cache[replicationId]
	cache[replicationId] = self

	local specificClassRemotes = remotes:FindFirstChild(className)
	if not specificClassRemotes then
		specificClassRemotes = Instance.new("Folder")
		specificClassRemotes.Name = className
		specificClassRemotes.Parent = remotes
	end

	if typeof(clients) == "Instance" then
		clients = { clients }
	end
	local replication = {
		remotes = specificClassRemotes,
		id = replicationId,
		clients = clients,
	}

	self.replication = replication

	if clients then
		for _, client in ipairs(clients) do
			replicateToClient(self, client)
		end
	else
		local connection = Players.PlayerAdded:Connect(function(client)
			replicateToClient(self, client)
		end)
		replication.connection = connection
		for _, client in ipairs(Players:GetPlayers()) do
			replicateToClient(self, client)
		end
	end

	self:call("replicate")

	return replication
end

function replication:addClient(client)
	local replication = self:getReplication()

	assert(client, "Attempt to addClient without client")
	assert(replication, "Attempt to addClient without replication")

	local clients = replication.clients
	if not clients then
		return
	end
	if table.find(clients, client) then
		return
	end

	table.insert(clients, client)

	replicateToClient(self, client)
end

function replication:addClients(clients)
	local replication = self:getReplication()

	assert(type(clients) == "table", "Attempt to addClients with invalid clients")
	assert(replication, "Attempt to addClients without replication")

	for _, client in ipairs(clients) do
		self:addClient(client)
	end
end

function replication:getReplication(...)
	local replication = self.replication
	if replication then
		return replication
	end

	replication = self:replicate(...)

	assert(replication, "Attempt to getReplication with no replication created")

	return replication
end

function replication:isReplicated()
	local replication = self.replication
	if replication then
		return replication
	end

	return false
end

function replication:unreplicate()
	local replication = self.replication

	assert(replication, "Attempt to unreplicate without replication")

	local clients = replication.clients or Players:GetPlayers()
	local id = replication.id
	for _, client in clients do
		replicatorRemotes.unreplicate:FireClient(client, id)
	end
	cache[id] = nil

	local connection = replication.connectiono
	if connection then
		connection:Disconnect()
	end

	-- TODO: Destroy remotes IF no other class instances are using them

	self.replication = nil
	self:call("unreplicate")
end

function replication:__serialize(serializedSelf)
	serializedSelf = Emitter.__serialize(self, serializedSelf)

	local newSerializedSelf = {}

	for attributeKey, attributeValue in pairs(serializedSelf) do
		if type(attributeValue) == "function" then
			continue
		end
		if attributeKey:sub(1, 1) == "_" then
			continue
		end
		if table.find(config.IGNORE_KEYS, attributeKey) then
			continue
		end
		newSerializedSelf[attributeKey] = attributeValue
	end

	newSerializedSelf = serializationModule.serializeCyclic(newSerializedSelf)

	return newSerializedSelf
end

return replication