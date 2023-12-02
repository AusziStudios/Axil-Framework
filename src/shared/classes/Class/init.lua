-- An abstract base class which is almost all classes are derrived from

local Class = {}
Class.className = "Class"
setmetatable(Class, Class)

local tools = _G("modules.tools")

local config = _G("config.Class")

for _, moduleName in ipairs(config.SUB_MODULES) do
	for methodName, method in pairs(require(script:WaitForChild(moduleName))) do
		Class[methodName] = method
	end
end

function Class:__init()
	-- To avoid errors on classes which call it
end

function Class:__serialize(serializedSelf)
	return serializedSelf
end

function Class:label()
	local className = self.className or "UNKNOWN_CLASS"
	local address = self.__address or "UNKNOWN_ADDRESS"

	local replication = self.replication
	local replicationString = ""
	if replication then
		local replicationId = replication.id
		if replicationId then
			replicationId = replicationId:sub(1, 5)
		else
			replicationId = "UNKNOWN_REP_ID"
		end
		replicationString = "/"..replicationId
	end

	return "{ "..className..": "..address..replicationString.." }"
end

return Class