extends Node2D

@export var starting_position := Vector2(256, 256)
@export var manager : PackedScene = load("res://scenes/game_scene/tile_manager/Tile_manager.tscn")
@export var player : PackedScene = preload("res://scenes/game_scene/player/player.tscn")

@export var levels : Dictionary[int, LevelDetails] = {
	1 : LevelDetails.new([[0, 0, 2, 0], [0, 1, 1, 0], [0, 0, 1, 1], [1, 1, 1, 0]], 64, 16)
}

func _ready() -> void:
	var tile_manager = manager.instantiate()
	var p = player.instantiate()

	tile_manager.position = Vector2.ZERO
	p.position = Vector2.ZERO
	# TODO: Figure out how to set this up
	p.set_starting_position(levels[1].gap, Vector2(4, 4), Vector2(levels[1].gap, levels[1].gap))
	tile_manager.level = levels[1]
	add_child(tile_manager)
	add_child(p)
	tile_manager.populate()
