extends Node2D

@export var tile : PackedScene = preload("res://scenes/game_scene/tile_manager/Tile.tscn")

# TODO: This needs to be in it's level scene
var grid_size := Vector2(4, 4)
var tile_size := 64
var starting_pos := Vector2(128, 128)
var tile_scale := 0.9

func _ready() -> void:
	for x in range(0, grid_size.x):
		for y in range(0, grid_size.y):
			var instance := tile.instantiate()
			instance.position = starting_pos * Vector2(x + 1, y + 1)
			instance.scale = Vector2(tile_scale, tile_scale)
			add_child(instance)

