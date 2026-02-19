extends Node2D
class_name TileManager

@export var tile : PackedScene = preload("res://scenes/game_scene/tile_manager/Tile.tscn")
@export var level: LevelDetails
var instances : Array[Array]

signal unsafe_tile

func populate() -> void:
	for x in range(0, level.grid_size.size()):
		var row : Array[Tile] = []
		for y in range(0, level.grid_size[0].size()):
			var instance := tile.instantiate()
			instance.position = Vector2.ZERO + (level.tile_size + level.inter_tile_gap)* Vector2(x + 1, y + 1)
			instance.tile_type = level.grid_size[y][x]
			instance.scale = _find_scale(level.tile_size)
			row.append(instance)
			add_child(instance)
		instances.append(row)

func _find_scale(tile_size: int) -> Vector2:
	var ratio = tile_size / 80.0
	return Vector2(ratio, ratio)

func _check_tile_status(centre: Vector2) -> bool:
	if centre.x < level.grid_size.size() and centre.y < level.grid_size[0].size() and 0 == level.grid_size[centre.y][centre.x]:
		unsafe_tile.emit()
		return false
	
	return true

func activate_starting_tiles() -> void:
	for x in range(0, level.grid_size.size()):
		instances[0][x].activate_tile()

func toggle_status(status: bool) -> void:
	for x in range(0, level.grid_size.size()):
		for y in range(0, level.grid_size[0].size()):
			if status:
				instances[x][y].hide_data()
			else:
				instances[x][y].set_data()

func new_centre(centre: Vector2) -> void:
	if _check_tile_status(centre):
		var borders := [centre + Vector2.UP, centre + Vector2.DOWN, centre + Vector2.RIGHT, centre + Vector2.LEFT]
		
		for x in range(0, level.grid_size.size()):
			for y in range(0, level.grid_size[0].size()):
				instances[x][y].hide_data()
	
		for p in borders:
			if is_valid(p):
				instances[p.x][p.y].flash_status()

func is_valid(border: Vector2) -> bool:
	return border.y >= 0 and border.y <= instances.size() - 1 and border.x >= 0 and border.x <= instances[0].size() - 1
