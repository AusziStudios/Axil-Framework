local config = {
	BIOME_RANDOM = os.time(),
	BIOME_SCALE = 350,
	MAP_SIZE = 600,
	MAX_HEIGHT = 2000,
	WIDTH_SCALE = 1,
	USE_TERRAIN = false, -- Convert the parts to terrain
	EXPONENTIAL_HEIGHT_MULTIPLIER = 1,
	SIN_HEIGHT_MULTIPLIER = 1, -- Set to 0 to disable
	HEIGHT_OFFSET = 2,

	-- For fractal noise
	OCTAVES = 3,
	LACUNARITY = 2,
	PERSISTENCE = 0.45,
	SCALE = 100,

	-- For biome fractal noise
	BIOME_OCTAVES = 3,
	BIOME_LACUNARITY = 2,
	BIOME_PERSISTENCE = 0.45,
	BIOME_SCALE = 100,
}

return config