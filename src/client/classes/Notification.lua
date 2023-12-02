local Notification = {}

local Replicator = _G("classes.Replicator")
Replicator:create("Notification", Notification)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

function Notification:__init(info)
	self.info = info

	self:onServer("send", function(clients)
		if not table.find(clients, Players.LocalPlayer) then
			return
		end

		self:send()
	end)
	self:onServer("updateInfo", function(newInfo)
		self.info = newInfo
	end)
end

function Notification:send()
	assert(self.replication, "Attempt to send Notification without replication information")
	
	local info = self.info

	assert(info, "Attempt to send Notification without info")

	local actualInfo = {
		Title = info.title,
		Text = info.text,
		Icon = info.icon,
		Duration = info.duration,
		Button1 = info.button1,
		Button2 = info.button2,
	}

	StarterGui:SetCore("SendNotification", actualInfo)
end

function Notification:updateInfo(newInfo)
	self.info = newInfo
end

return Notification