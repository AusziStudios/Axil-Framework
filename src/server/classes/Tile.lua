local Tile = {}

local template = _G("templates.Tile")

local Object = _G("classes.Object")
Object:create("Tile", Tile, template)

local tilesFolder = Instance.new("Folder")
tilesFolder.Name = "tiles"
tilesFolder.Parent = workspace

local config = _G("config.Tile")

local Terrain = workspace:WaitForChild("Terrain")

local widthScale = config.WIDTH_SCALE

local Body = _G("classes.Body")

local function fractalNoise(x, y, octaves, lacunarity, persistence, scale, seed)
	local value = 0

	local x1 = x 
	local y1 = y

	local amplitude = 1
	
	for i = 1, octaves do
		value += math.noise(x1 / scale, y1 / scale, seed) * amplitude
		
		y1 *= lacunarity
		x1 *= lacunarity

		amplitude *= persistence
	end

	return value
end

local SCALE = config.SCALE
local function getHeight(x, y)
	local height = fractalNoise(x, y, config.OCTAVES, config.LACUNARITY, config.PERSISTENCE, config.SCALE)
	local distance = math.abs(math.sqrt(x^2 / SCALE + y^2 / SCALE))
	height = (height * 0.75 + config.HEIGHT_OFFSET)
	if config.EXPONENTIAL_HEIGHT_MULTIPLIER > 0 then
		height *= (distance * config.EXPONENTIAL_HEIGHT_MULTIPLIER)
	end
	if config.SIN_HEIGHT_MULTIPLIER > 0 then
		height *= ((distance / SCALE) + 1/SCALE + 1) * config.SIN_HEIGHT_MULTIPLIER
	end
	height = math.clamp(height, 1, config.MAX_HEIGHT)
	return height
end

local function spiral(max, callback)
	local directions = {
		{0, 1}, --up
		{-1, 0}, --left
		{0, -1}, --down
		{1, 0}, --right
	}
	
	local coordinates = {}
	local coordinate = {0, 0}
	
	while #coordinate < max do
		for directionNumber, direction in ipairs(directions) do
			local nextDirection
			if directionNumber == #directions then
				nextDirection = directions[1]
			else
				nextDirection = directions[directionNumber + 1]
			end
			
			repeat
				if #coordinates >= max then
					break
				end
				
				coordinate[1] += direction[1]
				coordinate[2] += direction[2]
				
				table.insert(coordinates, {
					coordinate[1],
					coordinate[2],
				})
				
				callback(coordinate[1], coordinate[2], #coordinates)
				
				local allowNextDirection = true
				local targetCoordinate = {
					coordinate[1] + nextDirection[1],
					coordinate[2] + nextDirection[2],
				}
				for _, otherCoordinate in ipairs(coordinates) do
					if otherCoordinate[1] == targetCoordinate[1] and otherCoordinate[2] == targetCoordinate[2] then
						allowNextDirection = false
						break
					end
				end
			until allowNextDirection
		end
	end
end

local function makeModel(self, id)
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
	self.baseModelId = id

	local x = self.x
	local y = self.y
	local height = self.height
	
	local model = self:getModel()

	model:PivotTo(CFrame.new(x, 0, y))

	local top = model:FindFirstChild("Top")
	local bottom = model:FindFirstChild("Bottom")

	top.Anchored = true
	bottom.Anchored = true
	
	local width = top.Size.X * widthScale
	top.Size = Vector3.new(width, height, width)
	-- top.Size = Vector3.one * 5
	top:PivotTo(model:GetPivot() + Vector3.new(0, height / 2 + bottom.Size.Y / 2, 0))	

	bottom:Destroy()
	if config.USE_TERRAIN then
		Terrain:FillBlock(top:GetPivot(), top.Size, top.Material)
		Terrain:FillBlock(bottom:GetPivot(), bottom.Size, bottom.Material)
		model:Destroy()
	else
		model.Parent = tilesFolder
	end
end

function Tile:__init(id, x, y, height, temperature)
	Object.__init(self, id)

	self.x = x
	self.y = y
	self.height = height
	self.temperature = temperature

	makeModel(self, id)
end

local function lerpHeight(min, max, lerp)
	local diff = max - min
	return lerp * diff
end

local dist = config.MAP_SIZE
local biomes = {"ice", "snow", "rock", "tundra"}
function Tile.generate()
	local tiles = {}

	local max = -math.huge
	local min = math.huge
	for x = -dist, dist, 5 * widthScale do
		for y = -dist, dist, 5 * widthScale do
			local height = getHeight(x, y)
			if height > max then
				max = height
			end
			if height < min then
				min = height
			end
		end
	end

	spiral(config.MAP_SIZE, function(x, y, total)
		x, y = x * 5, y * 5
		local height = getHeight(x, y)

		-- local biomeId = math.noise(x / config.BIOME_SCALE, y / config.BIOME_SCALE, config.BIOME_RANDOM)
		local biomeId = fractalNoise(x, y, config.OCTAVES, config.LACUNARITY, config.PERSISTENCE, config.SCALE, config.BIOME_RANDOM)
		biomeId = math.floor((math.abs(biomeId) * 2) * #biomes + 0.5) + 1
		biomeId = math.clamp(biomeId, 1, #biomes)
		local biome = biomes[biomeId]
		-- local random = math.random(-20, 5) / 100
		-- local biome
		-- if height >= lerpHeight(min, max, 0.8 + random) then
		-- 	biome = "snow"
		-- elseif height >= lerpHeight(min, max, 0.6 + random) then
		-- 	biome = "rock"
		-- elseif height >= lerpHeight(min, max, 0.2 + random) then
		-- 	biome = "tundra"
		-- else
		-- 	biome = "ice"
		-- end

		local tile = Tile(biome, x, y, height, 0)

		if math.random(1, 100) <= 5 then
			local id = Body:randomId(function(item)
				return item.spawns and table.find(item.biomes, biome)
			end)

			if id then
				Body(tile, id)
			end
		end

		table.insert(tiles, tile)
		
		if total % 10 == 0 then
			print("Paus")
			task.wait(0.1)
			print("End paus")
		end
	end)

	print("Done")
end

function Tile:removeBody()
	print("[ Remove body ]")
end

return Tile