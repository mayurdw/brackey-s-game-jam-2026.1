extends Node2D

@export var starting_position := Vector2(256, 256)
@export var manager : PackedScene = load("res://scenes/game_scene/tile_manager/Tile_manager.tscn")
@export var player : PackedScene = preload("res://scenes/game_scene/player/player.tscn")
@export var levels : Dictionary[int, LevelDetails] = {
	1 : LevelDetails.new([
		[0, 0, 1, 0],
		[0, 1, 1, 0],
		[0, 0, 1, 1],
		[1, 1, 1, 0]],
		80,
		16)
}

var tile_manager : TileManager
var p : Player
var connections : Array[Vector2]


func _ready() -> void:
	tile_manager = manager.instantiate()
	p = player.instantiate()

	tile_manager.position = Vector2.ZERO
	p.position = Vector2.ZERO
	# TODO: Figure out how to set this up
	p.set_starting_position(levels[1].gap, Vector2(4, 4), Vector2(levels[1].gap, levels[1].gap))
	tile_manager.level = levels[1]
	add_child(tile_manager)
	add_child(p)

	p.connect("new_centre_position", _new_center_position)
	p.connect("level_completed", _level_completed)
	tile_manager.connect("unsafe_tile", _game_over)
	tile_manager.populate()

func _game_over() -> void:
	print("On unsafe tile, game over")
	p.controls_enabled = false

func _new_center_position(centre_position: Vector2) -> void:
	connections.append(centre_position)
	tile_manager.new_centre(centre_position)

func _level_completed() -> void:
	p.controls_enabled = false
