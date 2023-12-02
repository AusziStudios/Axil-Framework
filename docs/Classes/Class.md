[Go back to the classes index](index)

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

**:newFromTemplate(template, ...)**

---

**:inherit(...)**

# Iteration
Located in `Class.iterate`

*All iteration functions can be called on the original class, or any initialized classes.*

---

**:addInstance()**

---

**:getInstances()**

---

**:iter()**

An iteration function, loops through all instances.

For example

```lua
for 
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

**:iterAll(methodName**)