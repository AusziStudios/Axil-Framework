local template = {
	id = "baseBody",
	spawns = false,
	biomes = {},

	subClasses = {
		["naturalResources"] = {
			spawns = true,
			subClasses = {
				["tree"] = {
					biomes = {"tundra"}
				},
			}
		},
		["loot"] = {
			spawns = true,
			subClasses = {
				["crate"] = {
					biomes = {"ice"}
				},
				["ration"] = {
					biomes = {"ice", "rock", "tundra"}
				},
			},
		},
		["constructable"] = {
			subClasses = {
				["campfire"] = {

				},
				["tree"] = {
		
				},
			}
		},
		["bunker"] = {
			spawns = true,
			biomes = {"tundra"}
		}
	}
}

return template