local create = {}

local config = _G("config.Class")

local function createClass(self, className, class, superClasses, isInstance, ...)
	class.className = className
	class.__address = tostring(class):sub(10)

	if superClasses then
		superClasses = table.clone(superClasses)
	else
		superClasses = {}
	end
	if not table.find(superClasses, self) then
		table.insert(superClasses, 1, self)
	end
	for _, superClass in superClasses do
		for k, v in pairs(superClass) do
			if class[k] or table.find(config.UNINHERIT, k) then
				continue
			end
			class[k] = v
		end
	end

	local creationMethod = self["__create"]
	if creationMethod and not isInstance then
		creationMethod(class, ...)
	end

	class.__call = function(self, ...) --Creates a new instance
		local classInstance = createClass(self, self.className, {}, nil, true, ...)

		local initializeMethod = self["__init"]
		if initializeMethod then
			initializeMethod(classInstance, ...)
		end
		
		return classInstance
	end

	setmetatable(class, class)

	return class
end

function create:create(className, class, ...) 
	return createClass(self, className, class, nil, false, ...)
end

function create:multiCreate(className, class, superClasses, ...)
	return createClass(self, className, class, superClasses, false, ...)
end

function create:newFromPreset(preset, ...)	
	local classInstance = createClass(self, self.className or preset.className, preset, nil, true, ...)

	local initializeMethod = classInstance["__init"]
	if initializeMethod then
		initializeMethod(classInstance, table.unpack(classInstance.initParams))
	end
	
	return classInstance
end

function create:inherit(...)
	for _, object in ipairs({...}) do
		for key, value in pairs(object) do
			self[key] = value
		end
	end
end

-- Prevent direct class instances
function create.__call()
	error("Cannot create direct instances of Class")
end
create.new = create.__call

return create