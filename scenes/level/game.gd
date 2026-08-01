extends Node2D


@onready var player: CharacterBody2D = $Objects/Player

func _on_player_tool_use(tool: int, pos: Vector2) -> void:
	print("--- STEP 3: Signal received in game.gd! Tool ID: ", tool)
	var grid_pos = Vector2i(int(pos.x / 16), int(pos.y / 16))
	print("Calculated grid_pos: ", grid_pos)
	
	if tool == player.Tools.HOE:
		print("Checking GrassLayer cell at ", grid_pos)
		var cell = $Layers/GrassLayer.get_cell_tile_data(grid_pos) as TileData
		print("Grass TileData found? ", cell != null)
		if cell:
			print("Placing soil...")
			$Layers/SoilLayer.set_cells_terrain_connect([grid_pos], 0, 0)
	
	if tool == player.Tools.WATER:
		print("Checking SoilLayer cell at ", grid_pos)
		var soil_cell = $Layers/SoilLayer.get_cell_tile_data(grid_pos)
		print("Soil TileData found? ", soil_cell != null)
		if soil_cell:
			print("Placing water...")
			# Pick a random Source ID (0, 1, or 2) for the 3 tileset entries
			var random_water_id = randi_range(0, 2)
			$Layers/SoilWaterLayer.set_cell(grid_pos, random_water_id, Vector2i(0, 0))
