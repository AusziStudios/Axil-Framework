local create = {}

local config = _G("config.Class")

local tools = _G("modules.tools")

-- TODO: Remove all this junk:
-- local function createClass(self, className, class, superClasses, isInstance, ...)
-- 	class.className = className
-- 	class.__address = tostring(class):sub(10)

-- 	if superClasses then
-- 		superClasses = table.clone(superClasses)
-- 	else
-- 		superClasses = {}
-- 	end
-- 	if not table.find(superClasses, self) then
-- 		table.insert(superClasses, 1, self)
-- 	end
-- 	for _, superClass in superClasses do
-- 		for k, v in pairs(superClass) do
-- 			if class[k] or table.find(config.UNINHERIT, k) then
-- 				continue
-- 			end
-- 			class[k] = v
-- 		end
-- 	end

-- 	local creationMethod = self["__create"]
-- 	if creationMethod and not isInstance then
-- 		creationMethod(class, ...)
-- 	end

-- 	class.__call = function(self, ...) --Creates a new instance
-- 		local classInstance = createClass(self, self.className, {}, nil, true, ...)

-- 		local initializeMethod = self["__init"]
-- 		if initializeMethod then
-- 			initializeMethod(classInstance, ...)
-- 		end
		
-- 		return classInstance
-- 	end

-- 	setmetatable(class, class)

-- 	return class
-- end

-- function create:create(className, class, ...) 
-- 	return createClass(self, className, class, nil, false, ...)
-- end

-- function create:multiCreate(className, class, superClasses, ...)
-- 	return createClass(self, className, class, superClasses, false, ...)
-- end

-- function create:newFromPreset(preset, ...)	
-- 	local classInstance = createClass(self, self.className or preset.className, preset, nil, true, ...)

-- 	local initializeMethod = classInstance["__init"]
-- 	if initializeMethod then
-- 		initializeMethod(classInstance, table.unpack(classInstance.initParams))
-- 	end
	
-- 	return classInstance
-- end

-- function create:inherit(...)
-- 	for _, object in ipairs({...}) do
-- 		for key, value in pairs(object) do
-- 			self[key] = value
-- 		end
-- 	end
-- end

-- Prevent direct class instances
-- function create.__call()
-- 	error("Cannot create direct instances of Class")
-- end
-- create.new = create.__call

function create:inherit(class)
	tools.inherit(self, class)
end

function create:inheritMultiple(others, class)
	others = table.clone(others)
	table.insert(others, 1, self)
	tools.inheritMultiple(others, class)
end

function create:inheritFrom(class)
	tools.inherit(class, self)
end

function create:inheritMultipleFrom(classes)
	tools.inherit(classes, self)
end

function create:create(className, class, ...)
	local address = tostring(class):match("table: 0x(.*)")
	tools.inherit(self, class)
	class.className = className
	class.__address = address

	local __create = class["__create"]
	if __create then
		__create(class, ...)
	end

	return class
end

function create:new(...)
	local class = {}

	self.__address = tostring(class):match("table: 0x(.*)")
	tools.inherit(self, class)

	local __init = class["__init"]
	if __init then
		__init(class, ...)
	end

	return class
end

setmetatable(create, {
	__call = create.new
})

return create