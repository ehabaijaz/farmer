extends Node2D

@onready var player: CharacterBody2D = $Objects/Player
var plant_scene = preload('res://scenes/plant.tscn')
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect 
@export var daytime_gradient : Gradient

func _process(delta: float) -> void:
	var daytime_point : float = 1.0 - ($DayTimer.time_left/$DayTimer.wait_time)
	$CanvasModulate.color = daytime_gradient.sample(daytime_point)
	if Input.is_action_just_pressed("ui_focus_next"):
		day_switch()
func _on_player_tool_use(tool: int, pos: Vector2) -> void:
	var grid_pos = Vector2i(int(pos.x / 16), int(pos.y / 16))
	
	if tool == player.Tools.HOE:
		var cell = $Layers/GrassLayer.get_cell_tile_data(grid_pos) as TileData
		if cell:
			print("Placing soil...")
			$Layers/SoilLayer.set_cells_terrain_connect([grid_pos], 0, 0)
	
	if tool == player.Tools.WATER:
		var soil_cell = $Layers/SoilLayer.get_cell_tile_data(grid_pos)
		if soil_cell:
			var random_water_id = randi_range(0, 2)
			$Layers/SoilWaterLayer.set_cell(grid_pos, random_water_id, Vector2i(0, 0))
	if tool== player.Tools.AXE:
		for tree in get_tree().get_nodes_in_group('Trees'):
			if tree.position.distance_to(pos) < 10:
				tree.hit()


func _on_player_seed_use(seed_enum: int, pos: Vector2) -> void:
	var grid_pos = Vector2i(int(pos.x / 16),int(pos.y / 16))
	var cell = $Layers/SoilLayer.get_cell_tile_data(grid_pos) as TileData
	if cell:
		var plant_pos = Vector2(grid_pos.x * 16 + 8, grid_pos.y * 16 - 4)
		var plant = plant_scene.instantiate()
		plant.setup(seed_enum, grid_pos)
		$Objects.add_child(plant)
		plant.position = plant_pos
		


func day_switch():
	var tween = create_tween()
	tween.tween_property($CanvasLayer/ColorRect, "color:a", 1.0,1.0)
	tween.tween_callback(level_reset)
	tween.tween_interval(1.0)
	tween.tween_property($CanvasLayer/ColorRect, 'color:a',0.0,1.0)

func level_reset():
	for plant in get_tree().get_nodes_in_group('Plants'):
		plant.grow(plant.grid_pos in $Layers/SoilWaterLayer.get_used_cells())
	$Layers/SoilWaterLayer.clear()
	$DayTimer.start()
	
