[Go back to the classes index](Index.md)

---

Located in `shared.classes.Class`

# General
Located in `Class.init`

---

**:label(): string** 

Returns a string which can be used to uniquely identify the class instance. For use in debugging only. Always includes the table's memory address, and sometimes truncated replicationId if replicated.

---
# Creation
Located in `Class.create`

---

**:create(className, class, ...)**

---

**:multiCreate(className, class, superClasses, ...)**

---

**:newFromPreset(preset, ...)**

---

**:inherit(...)**

# Iteration
Located in `Class.iterate`

*All iteration functions can be called on the original class, or any initialized classes.*

---

**:addInstance()**

Instances are automatically added when initialized.

---

**:getInstances(): table**

Returns an array of all instances added through `:addInstances()` (instances are automatically added).

```lua
for _, self in ipairs(Class:getInstances()) do
	-- Preform actions with self
end
```

It's more efficient to use iterator functions.

---

**:iter()**

An iteration function, loops through all instances.

For example

```lua
for _, self in Class:iter() do
	-- Preform actions with self
end
```

---

**:iterCall(callback)**

Calls the given function for each class, passing the instance.

```lua
Class:iterCall(function(self)
	-- Preform actions with self
end)
```

---

**:iterAll(methodName, ...)**

Calls a method on all instances, passing the paramaters.

Example, using the [Object](Object.md) class. It runs `:getModel()` on all instances, which makes every instance create their model under workspace.
```lua
Object:iterAll("getModel", workspace)
```

What is actually being run:
```lua
for _, self in Object:iter() do
	self:getModel(workspace)
end
```
