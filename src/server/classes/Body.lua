local Body = {}

local template = _G("templates.Body")

local Object = _G("classes.Object")
Object:create("Body", Body, template)

local bodiesFolder = Instance.new("Folder")
bodiesFolder.Name = "bodies"
bodiesFolder.Parent = workspace

local config = _G("config.Body")

function Body:__init(tile, id, rotation)
	Object.__init(self, id)

	local tileModel = tile:getModel()
	local model = self:getModel()

	rotation = rotation or math.random(0, 3)

	local primary = model.PrimaryPart
	local top = tileModel:FindFirstChild("Top")

	local pivot = top:GetPivot()
	pivot += Vector3.new(0, top.Size.Y / 2 + primary.Size.Y / 2, 0)
	pivot *= CFrame.Angles(0, math.rad(90 * rotation), 0)
	model:PivotTo(pivot)

	model.Parent = bodiesFolder

	tile.body = self
end

-- local ids = {"ration", "campfire", "crate", "tree"}
-- function Body.generate(tile)
-- 	if tile.body then
-- 		return
-- 	end

-- 	local id = ids[math.random(1, #ids)]

-- 	local self = Body(tile, id)
-- 	tile.body = self

-- 	return self
-- end

return Body