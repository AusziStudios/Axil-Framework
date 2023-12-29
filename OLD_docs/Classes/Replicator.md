[Go back to the classes index](Index.md)

---

# Overview

It is the first pre-included class to not exist in `src/shared`, but twice in `src/client` and `src/server`.

# Server

## Replication

Allows for classes to be "copied" and distrubted to clients, and sets up the listeners.

---

**:replicate(clients)**

*If given no clients, it will replicate to ever client, including new ones which join later.*
Can receive a table of clients, or a single client not in a table.

---

**:addClient(client)**

If `replicate` was called with specific clients, this client will also be added.

---

**:addClients(clients)**

Adds multiple clients at once.

---

**:getReplication()**

*Reccomended to not use this*

Returns the replication data which usually looks something like this:
```lua
{
	-- The id of the specific class instance, for between the client and server
	id = "286dd26b-31da-4f86-b460-6030ba07ace9",
	-- A table of remotes for emitter events
	remotes = Folder,
	-- The current owner, if set
	owner = Player,
	-- A list of all currently replicated clients, if specified
	clients = {Player},
}
```

---

## Listener

---

**:establish(eventName)**

Opens a remote event to send traffic for a specific class and event.
Automatically used when calling/receiving events from the clinet.
Not usually neccecary to call.

---

**:callClient(eventName, client, ...)**

---

**:callClients(eventName, clients, ...)**

---

**:callAllClients(eventName, ...)**

Calls all currently replicated clients.

---

**:onServer(eventName, callback)**

---

## Ownership

Ownership is used to prescribe a specific player a certain class, such as theiri nventory, where only they can take items and remove items.

Nothing about ownership is ever exposed to the client.

---

**:setOwner(client)**

Sets a certain player as the new owner.

---

**:getOwner()**

If there is an owner, returns them. Otherwise, places a warning.

---

**:onServerOwner(eventName, callback, ...)**

Like `onServer`, except only calls the callback if the owner is calling the server.
Still passes the client to the callback.

---

**:callOwner(eventName, ...)**

Similar to `callClient`, except automatically passes the current owner.
Throws an error if there is no owner.

---

# Client

The client has a lot less access to behavior.