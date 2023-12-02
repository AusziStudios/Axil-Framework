local NaturalResource = {}

local Object = _G("classes.Object")
local NaturalResourceTemplate = _G("templates.NaturalResource")

Object:create("NaturalResource", NaturalResource, NaturalResourceTemplate, "NaturalResource")

local Item = _G("classes.Item")

local playerData = _G("data.playerData")

local Notification = _G("classes.Notification")

local function endCollect(self, player, interactionQueue, proximityPrompt)
	local beginTime = interactionQueue[player]

	if not beginTime then
		warn("Attempt to endCollect without beginTime", player)
		return
	end

	interactionQueue[player] = nil
	if
		os.clock() - beginTime + 0.1 < proximityPrompt.HoldDuration
		or os.clock() - beginTime - 1 > proximityPrompt.HoldDuration
	then
		local abnormalNotification = Notification({
			title = "Untimely Error",
			text = "You preformed a timed interaction at an abnormal speed. This may be due to a slow connection or a bug.",
			duration = 5,
		})
		abnormalNotification:sendOnce(player)
		return
	end

	local hits = self.hits or 1
	local hitsLeft = (self.hitLeft or self.hits or 1) - 1
	self.hitLeft = hitsLeft

	local collectedResources = {}

	for _, resource in self.resources or {} do
		local random = math.clamp(math.random() * 100, 0, 100)
		if random > resource.chance then
			continue
		end

		table.insert(collectedResources, {
			id = resource.id,
			amount = math.random(resource.min, resource.max),
		})
	end

	local title = "Collected "
		.. (self.displayName or self.id or "[ ERROR ]")
		.. " ("
		.. tostring(hits - hitsLeft)
		.. " of "
		.. tostring(hits)
		.. ")"
	local text = ""

	local items = {}

	for index, resource in ipairs(collectedResources) do
		local item = Item(resource.id)

		text = text .. item.displayName .. " (x" .. resource.amount .. ")"
		if index ~= #collectedResources then
			text ..= "\n"
		end
		
		for itemCount = 1, resource.amount do
			item = item or Item(resource.id)

			if not self.instant then
				local model = item:getModel(workspace)
				local characterPivot = player.Character:GetPivot()
				local cframe = characterPivot or CFrame.new()
				cframe = cframe * CFrame.Angles(0, math.rad(math.random(0, 360)), 0) 
				cframe = cframe * CFrame.new(math.random(15, 50) / 10, 0, 0)
				model:PivotTo(cframe)
			end
			
			table.insert(items, item)
			item = nil
		end

		if self.instant then
			playerData[player].inventory:addItems(items)
		end
	end
	if #collectedResources == 0 then
		text = "Couldn't find any resources!"
	end

	local collectionNotification = Notification({
		title = title,
		text = text,
		duration = self.duration or 1,
	})
	collectionNotification:sendOnce(player)

	proximityPrompt.ActionText = "Collect (" .. tostring(hits - hitsLeft) .. " of " .. tostring(hits) .. ")"

	if hitsLeft <= 0 then
		self:call("collected", player)
		self:destroy()
	end
end
 
function NaturalResource:__init(...)
	Object.__init(self, ...)

	local model = self:getModel(workspace)
	model:PivotTo(CFrame.new(math.random(-50, 50), 10, math.random(-50, 50)) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0))

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.HoldDuration = self.duration or 1
	proximityPrompt.ObjectText = self.displayName or self.id or "ERROR"
	proximityPrompt.ActionText = "Collect (0 of " .. tostring(self.hits or 1) .. ")"
	proximityPrompt.Parent = model.PrimaryPart
	self:replicate()

	local interactionQueue = {}
	self:onClient("beginCollect", function(player)
		interactionQueue[player] = os.clock()
	end)
	self:onClient("endCollect", function(player)
		endCollect(self, player, interactionQueue, proximityPrompt)
	end)
end

return NaturalResource
