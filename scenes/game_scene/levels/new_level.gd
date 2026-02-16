extends Node2D

@export var min_distance_for_player := 128
@export var starting_position := Vector2(256, 256)
@export var manager : PackedScene = load("res://scenes/game_scene/tile_manager/Tile_manager.tscn")

@export var levels : Dictionary[int, LevelDetails] = {
	1 : LevelDetails.new([[0, 0, 2, 0], [0, 1, 1, 0], [0, 0, 1, 1], [1, 1, 1, 0]], 64, 16)
	}

func _ready() -> void:
	var tile_manager = manager.instantiate()

	tile_manager.level = levels[1]
	tile_manager.position = starting_position
	add_child(tile_manager)
	tile_manager.populate()
