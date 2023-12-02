[Go back to the modules index](index)

---

*These functions are also available in the global table, \_G.*

--- 

**_G.require()** 

*This function is also available by directly calling _G:*
```lua
-- Valid ways of calling this
resourceModule.require("path")
_G.require("path")
_G("path") -- Quickest
```

This is how paths are searched for:
- In the current directory, check if there is an instance at the path
  - If there is
    - If it's a module script, return the required script
    - If it's not a module script, just return it
  - If there isn't, is there a next directory?
    - If there is, go to it and continue the loop
    - If there isn't, error

These are the directories that are searched. ServerScriptService is searched first.
1. ServerScriptService (`src/server`)
2. ServerStorage
   - plugins (`src/plugins`)
3. ReplicatedStorage (`src/shared`)
4. StarterPlayerScripts (`src/client`)
5. StarterCharacterScripts'

So, when you do this:
```lua
_G("classes.Class")
```
It does this:
- Search ServerScriptService
  - No instance at `ServerScriptService.classes.Class`
- Search ServerStorage
  - No instance at `ServerStorage.classes.Class`
- Search ReplicatedStorage
  - Found instance at `ReplicatedStorage.classes.Class`
  - It is a module script, return the required script.

If you do something like this:
```lua
_G("classes.Replicator")
```
It can do different things.

This is because replicator is located in `src/client` *and* `src/server`, the two different versions for the client and the server.

If the running this script is on the server, server script service will be checked first, and it will be found there.

If the running this script is on the client, Roblox doesn't replicate ServerScriptService so it will appear empty. Replicator will be found in the 4th directory, ReplicatedStorage.

---