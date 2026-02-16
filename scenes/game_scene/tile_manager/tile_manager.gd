extends Node2D
class_name TileManager

@export var tile : PackedScene = preload("res://scenes/game_scene/tile_manager/Tile.tscn")
@export var level: LevelDetails
@export var tile_scale : Vector2 = Vector2.ONE

func populate() -> void:
	for x in range(0, level.grid_size.size()):
		for y in range(0, level.grid_size.size()):
			var instance := tile.instantiate()
			instance.position = Vector2.ZERO + (level.tile_size + level.inter_tile_gap)* Vector2(x + 1, y + 1)
			instance.scale = tile_scale
			add_child(instance)
