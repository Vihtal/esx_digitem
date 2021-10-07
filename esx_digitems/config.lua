Config = {}

Config.Locale = "en" --en, tw

-- The unit is milliseconds
Config.SpawnWaitMin = 10000
Config.SpawnWaitMax = 30000

Config.DigTime = 10000

Config.Digs = {
	{
		-- If you want to use random item please follow this example:
		-- digItem = {{"clam", 1, "蛤蠣"}, {"stone", 1, "石頭"}, ...},
		
		digItem = {{"clam", 1, "Clams"}}, needTool = "shovel", toolLabel = "Shovel",
		x = -2165.57, y = -462.55, z = 2.38, areaRange = 9, maxSpawn = 15, markerColor = {255, 179, 102},
		breakToolPercent = 5, blips = true, blipName = "Dig Site"
	},

	{
		digItem = {{"watermelon", 3, "WaterMelon"}}, needTool = "shovel", toolLabel = "Shovel",
		x = 2037.7, y = 4907.65, z = 41.86, areaRange = 35, maxSpawn = 30, markerColor = {0, 255, 0},
		breakToolPercent = 5, blips = false, blipName = "WaterMelons"
	}
}