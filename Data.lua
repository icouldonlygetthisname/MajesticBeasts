local _, ns = ...

-- Lure spots for the Midnight skinning Majestic Beasts.
-- x/y are zone map coordinates (0-100). The spots are small: stand on foot
-- until the "Sixth Sense" debuff appears, then use the lure.
-- points = Skinning specialization points needed to unlock the lure recipe.
ns.BEASTS = {
	{
		beast = "Gloomclaw",
		kind = "Cat",
		lureID = 238652,
		recipeID = 1225943,
		lureName = "Majestic Eversong Lure",
		mapID = 2395,
		zone = "Eversong Woods",
		x = 41.95, y = 79.70,
		points = 0,
		note = "South of the zone, a little east of Windrunner Spire.",
	},
	{
		beast = "Silverscale",
		kind = "Turtle",
		lureID = 238653,
		recipeID = 1225944,
		lureName = "Majestic Zul'Aman Lure",
		mapID = 2437,
		zone = "Zul'Aman",
		x = 47.55, y = 53.65,
		points = 10,
		note = "East side of the zone, UNDER the large bridge by the small lake, not on top of it.",
	},
	{
		beast = "Lumenfin",
		kind = "Sporeglider",
		lureID = 238654,
		recipeID = 1225945,
		lureName = "Majestic Harandar Lure",
		mapID = 2413,
		zone = "Harandar",
		x = 66.62, y = 47.84,
		points = 20,
		note = "East of the zone, just outside Har'athir.",
	},
	{
		beast = "Umbrafang",
		kind = "Shredclaw",
		lureID = 238655,
		recipeID = 1225946,
		lureName = "Majestic Voidstorm Lure",
		mapID = 2405,
		zone = "Voidstorm",
		x = 54.13, y = 65.25,
		points = 30,
		note = "In a ravine a little north of the main hub, The Howling Ridge.",
	},
	{
		beast = "Netherscythe",
		kind = "Grand Beast",
		lureID = 238656,
		recipeID = 1225948,
		lureName = "Grand Beast Lure",
		mapID = 2405,
		zone = "Voidstorm",
		x = 43.20, y = 82.82,
		points = 40,
		note = "A little south of Locus Point.",
	},
}
