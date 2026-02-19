extends Node2D

@export var starting_position := Vector2(256, 256)
@export var manager : PackedScene = load("res://scenes/game_scene/tile_manager/Tile_manager.tscn")
@export var player : PackedScene = preload("res://scenes/game_scene/player/player.tscn")
var levels : Dictionary[int, LevelDetails] = {
	0 : LevelDetails.new([
		[1, 0, 1, 0],
		[1, 1, 1, 0],
		[1, 0, 1, 1],
		[1, 1, 1, 0]],
		80,
		16),
	1 : LevelDetails.new([
		[0, 1, 1, 0, 1, 1, 1, 0],
		[1, 1, 0, 1, 0, 0, 1, 0],
		[0, 1, 1, 0, 1, 0, 0, 0],
		[0, 1, 1, 1, 1, 0, 0, 0],
		[0, 0, 1, 1, 0, 1, 0, 1],
		[1, 0, 0, 1, 1, 1, 1, 0],
		[1, 0, 1, 1, 1, 0, 0, 0],
		[1, 1, 0, 0, 1, 1, 1, 0],
		[0, 1, 0, 0, 1, 0, 1, 1]
		],
		80,
		16)
}
@export var level: int

var tile_manager : TileManager
var p : Player
var connections : Array[Vector2]

signal level_lost
signal level_won

func _ready() -> void:
	tile_manager = manager.instantiate()
	p = player.instantiate()

	tile_manager.position = Vector2.ZERO
	p.position = Vector2.ZERO
	p.set_starting_position(
		levels[level].gap, 
		Vector2(levels[level].grid_size.size(), levels[level].grid_size[0].size()), 
		Vector2(levels[level].gap, levels[level].gap)
	)
	tile_manager.level = levels[level]
	add_child(tile_manager)
	add_child(p)

	p.connect("new_centre_position", _new_center_position)
	p.connect("level_completed", _level_completed)
	tile_manager.connect("unsafe_tile", _game_over)
	tile_manager.populate()

func _game_over() -> void:
	p.controls_enabled = false
	level_lost.emit()

func _new_center_position(centre_position: Vector2) -> void:
	connections.append(centre_position)
	tile_manager.new_centre(centre_position)

func _level_completed() -> void:
	p.controls_enabled = false
	level_won.emit()
