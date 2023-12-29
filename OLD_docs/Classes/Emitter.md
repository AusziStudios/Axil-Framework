[Go back to the classes index](Index.md)

---

A class which runs synchronous events without crossing the client-server boundary.

Located in `shared.Emitter`.

---

**:call(eventName, ...)**

---

**:on(eventName, callback)**

---

**:hasBindings(eventName)**

Returns true if any callbacks have been registered for a specific `eventName` using `:on()`.

---