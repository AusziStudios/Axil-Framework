local template = {
	id = "baseTile",

	subClasses = {
		-- ["water"] = {
		-- 	-- update = function(self)
		-- 	-- 	local temperature = self.temperature
		-- 	-- 	if temperature <= 0 then
		-- 	-- 		self:removeBody()
		-- 	-- 		self:changeInto("ice")
		-- 	-- 		return
		-- 	-- 	end
		-- 	-- end
		-- },
		["ice"] = {
			-- update = function(self)
			-- 	local temperature = self.temperature
			-- 	if temperature > 0 then
			-- 		self:removeBody()
			-- 		self:changeInto("water")
			-- 		return
			-- 	end
			-- end
			possibleBodies = {
				"naturalResources",
				""
			},
		},
		["rock"] = {
		},
		["tundra"] = {
			-- update = function(self)
			-- 	local temperature = self.temperature
			-- 	if temperature <= -15 then
			-- 		self:changeInto("snow")
			-- 		return
			-- 	end
			-- end
		},
		["snow"] = {
			-- update = function(self)
			-- 	local temperature = self.temperature
			-- 	if temperature > -15 then
			-- 		self:changeInto("snow")
			-- 		return
			-- 	end
			-- end
		},
	}
}

return template