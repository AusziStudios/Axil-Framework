local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local classes = ReplicatedStorage.classes

local tools = _G("modules.tools")

local serializationModule = {}

local ignoredKeys = {
	"temp",
	"parent",
}

--Instance serialization

function serializationModule.serializeLocation(instance) --[DEPRICATED] Will turn an instance into a table, which can be saved in datastores. Use unserializeLocation to get back the instance.
	local currentPath = {}
	local currentInstance = instance
	local currentParent = currentInstance.Parent
	local valid = true
	while currentParent ~= nil do
		if currentInstance == game then
			--table.insert(currentPath, 1, game.Name)
			break
		end
		--[[for _, child in currentParent:GetChildren() do
			if child.Name == currentInstance.Name and child ~= currentInstance then
				warn("Attempt to serialize location with conflicting children")
				valid = false
				break
			end
		end]]
		if not valid then
			break
		end
		table.insert(currentPath, 1, currentInstance.Name)
		currentInstance = currentParent
		currentParent = currentInstance.Parent
	end
	if valid then
		return currentPath
	else
		warn("BRUH ERROR")
	end
end

function serializationModule.unserializeLocation(path) --[DEPRICATED] Turns a table created by serializeLocation back into its original instance. Does not create a new instance, only finds one at the path.
	local currentInstance = game
	local valid = true
	for i = 1, #path do
		--[[for _, child in currentInstance:GetChildren() do
			if child.Name == path[i] and child ~= currentInstance:FindFirstChild(path[i]) then
				warn("Attempt to unserialize location with conflicting children")
				valid = false
				break
			end
		end]]

		currentInstance = currentInstance:FindFirstChild(path[i])
	end
	if valid then
		return currentInstance
	end
end

--General serialization
local function serialize(o)
	local t = typeof(o)
	if t == "table" then
		o = table.clone(o)
		for k, v in o do
			if table.find(ignoredKeys, k) then --Prevent stack overflow
				o[k] = nil
				continue
			end
			o[serialize(k)] = serialize(v)
		end

		return o
	elseif t == "nil" or t == "boolean" or t == "string" then
		return o
	elseif t == "number" then
		if o == math.huge then
			return {type = "specialNumber", value = "huge"}
		else
			return o
		end
	elseif t == "Instance" then
		return nil
	elseif t == "Vector2" then
		return {type = "Vector2", value = {o.X, o.Y}}
	elseif t == "Vector3" then
		return {type = "Vector3", value = {o.X, o.Y, o.Z}}
	elseif t == "CFrame" then
		return {type = "CFrame", value = table.pack(o:GetComponents())}
	elseif t == "Color3" then
		return {type = "Color3", value = {o.R, o.G, o.B}}
	elseif t == "BrickColor" then
		return {type = "BrickColor", value = BrickColor.Number}
	elseif t == "UDim" then
		return {type = "UDim", value = {o.Scale, o.Offset}}
	elseif t == "UDim2" then
		return {type = "Udim2", value = {o.X.Scale, o.X.Offset, o.Y.Scale, o.Y.Offset}}
	elseif t == "EnumItem" then
		local a1 = string.split(tostring(o), ".")
		return {type = "EnumItem", value = {a1[2], a1[3]}}
	else
		--warn("No searialization for "..t..", leaving nil")
		return nil
	end
end

local function unserialize(o)
	local t = typeof(o)
	if t == "table" then
		t = o["type"]
		local v = o["value"]
		if t == "specialNumber" then
			if v == "huge" then
				return math.huge
			end
		elseif t == "Vector2" then
			return Vector2.new(unpack(v))
		elseif t == "Vector3" then
			return Vector3.new(unpack(v))
		elseif t == "CFrame" then
			return CFrame.new(unpack(v))
		elseif t == "Color3" then
			return Color3.new(unpack(v))
		elseif t == "BrickColor" then
			return BrickColor.new(v)
		elseif t == "UDim" then
			return UDim.new(unpack(v))
		elseif t == "UDim2" then
			return UDim2.new(unpack(v))
		elseif t == "EnumItem" then
			return Enum[v[1]][v[2]]
		elseif t == "Instance" then
			return nil
		else
			for k, v in pairs(o) do
				o[unserialize(k)] = unserialize(v)
			end

			local className = o["className"]
			if className then
				local class = classes:FindFirstChild(className)
				if class then
					class = require(class)

					o.methods = class.methods
					o.events = class.events

					local metatable = getmetatable(class)
					if metatable then
						setmetatable(o, metatable)
					end
				end
			end
			return o
		end
	elseif t == "nil" or t == "boolean" or t == "number" or t == "string" then
		return o
	else
		warn("No searialization for "..t..", leaving nil")
		return nil
	end
end

function serializationModule.serialize(object) --Object can be a table or most other value types. Turns the value type or the value types in the table into data-storable objects.
	if typeof(object) ~= "table" then
		warn("Attempt to fully serialize non-table")
		return
	end

	object = table.clone(object)
	local serialized = serialize(object)
	return serialized
end

function serializationModule.unserialize(object) --Turns a serialized object back into its original form.
	if typeof(object) ~= "table" then
		warn("Attempt to fully unserialize non-table")
		return {}
	end

	object = table.clone(object)	
	local unserialized = unserialize(object)
	return unserialized
end

--[[

Structure of serialized Cyclic table:

{
	parent = "table: 00000000-0000-0000-0000-000000000000", -- The address of the top-directory table
	tables = {
		["table: 00000000-0000-0000-0000-000000000000"] = {}, -- address : table
	}
}

--]]

function serializationModule.serializeCyclic(unserialized)
	assert(unserialized, "Attempt to unserializeCyclic with invalid object")

	if type(unserialized) ~= "table" then
		return unserialized
	end

	local cloned = tools.respectClone(unserialized)
	local expanded = tools.expandTable(cloned)

	--Assign labels
	local labeledItems = {}
	local parentLabel = nil
	for _, newObject in pairs(expanded) do
		--Create new unique label
		local label = nil
		repeat
			local exists = false
			label = "table: " .. HttpService:GenerateGUID(false)

			for _, otherObject in ipairs(expanded) do
				for key, value in pairs(otherObject) do
					if key == label or value == label then
						exists = true
						break
					end
				end
				if exists then
					break
				end
			end
		until not exists and label

		if cloned == newObject then
			parentLabel = label
		end

		labeledItems[label] = newObject		
	end

	--Replace any tables inside tables with labels
	for _, newObject in pairs(labeledItems) do
		for key, value in pairs(newObject) do
			for otherLabel, otherObject in pairs(labeledItems) do
				if otherObject == key and type(key) == "table" then
					key = otherLabel
				end
				if otherObject == value and type(value) == "table" then
					value = otherLabel
				end
			end
			newObject[key] = value
		end
	end

	return {
		parent = parentLabel,
		tables = labeledItems,
	}
end

function serializationModule.unserializeCyclic(serialized)
	if type(serialized) ~= "table" then
		return serialized
	end

	local parent = serialized.parent
	local tables = serialized.tables

	assert(type(parent) == "string", "Attempt to unserializeCyclic with invalid parent")
	assert(type(tables) == "table", "Attempt to unserializeCyclic with invalid tables")

	local newTables = {}
	for objectLabel, object in pairs(tables) do
		newTables[objectLabel] = table.clone(object)
	end

	for objectLabel, object in pairs(newTables) do
		for key, value in pairs(object) do
			if newTables[key] then
				key = newTables[key]
			end
			if newTables[value] then
				value = newTables[value]
			end
			object[key] = value
		end
	end

	return newTables[parent]
end

function serializationModule.serializeAll(object)
	object = serializationModule.serializeCyclic(object)
	object = serializationModule.serialize(object)

	return object
end

function serializationModule.unserializeAll(object)
	object = serializationModule.unserialize(object)
	object = serializationModule.unserializeCyclic(object)

	return object
end

return serializationModule