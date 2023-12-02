local Notification = {}

local Replicator = _G("classes.Replicator")
Replicator:create("Notification", Notification)

function Notification:__init(info, clients)
    Replicator.__init(self, info, clients)
    if self.replication then
        return
    end
    self:replicate()
end

function Notification:send(clients)
    if type(clients) ~= "table" then
        clients = {clients}
    end
    self:call("send", clients)
end

function Notification:sendOnce(clients)
    self:send(clients)
    self:unreplicate()
    table.clear(self)
end

function Notification:updateInfo(newInfo)
    self.info = newInfo

    self:call("updateInfo", newInfo)
end

return Notification