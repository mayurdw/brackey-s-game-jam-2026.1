extends Node2D

@export var tile : PackedScene = preload("res://scenes/game_scene/tile_manager/Tile.tscn")

# TODO: This needs to be in it's level scene
var grid_size := Vector2(8, 8)
var tile_size := 32
var starting_pos : Vector2 = Vector2(32, 32)
var tile_scale := 0.5

func _ready() -> void:
	for x in range(0, grid_size.x):
		for y in range(0, grid_size.y):
			var instance := tile.instantiate()
			instance.position = starting_pos + tile_size * Vector2(x + 1, y + 1)
			instance.scale = Vector2(tile_scale, tile_scale)
			add_child(instance)

