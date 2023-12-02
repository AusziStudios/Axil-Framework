--Client

local NaturalResource = {}

local Object = _G("classes.Object")
local NaturalResourceTemplate = _G("templates.NaturalResource")
Object:create("NaturalResource", NaturalResource, NaturalResourceTemplate, "NaturalResource")

function NaturalResource:__init()
	local model = self.model
	assert(model, "Missing model for NaturalResource")
	local primaryPart = model:WaitForChild("Part")

	local proximityPrompt = primaryPart:WaitForChild("ProximityPrompt")
	proximityPrompt.PromptButtonHoldBegan:Connect(function()
		self:call("beginCollect")
	end)
	proximityPrompt.Triggered:Connect(function()
		self:call("endCollect")
	end)
end

return NaturalResource