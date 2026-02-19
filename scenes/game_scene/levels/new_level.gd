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

@onready var start_timer: Timer = $"Start Timer"
@onready var game_timer: Timer = $"Game Timer"

var tile_manager : TileManager
var p : Player
var connections : Array[Vector2]
var start_count : int = 3

signal level_lost
signal level_won
signal remaining_start_count(remaining_time: int)
signal game_time(current_time_in_secs: int)

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
	start_timer.start()
	p.controls_enabled = false
	tile_manager.toggle_status(false)

func _game_over() -> void:
	p.controls_enabled = false
	level_lost.emit()

func _new_center_position(centre_position: Vector2) -> void:
	connections.append(centre_position)
	tile_manager.new_centre(centre_position)

func _level_completed() -> void:
	p.controls_enabled = false
	level_won.emit()


func _on_start_timer_timeout() -> void:
	start_count -= 1
	remaining_start_count.emit(start_count)
	if start_count <= 0:
		p.controls_enabled = true
		game_timer.one_shot = false
		game_timer.start(1.0)
		tile_manager.toggle_status(true)
		start_timer.stop()

func _on_game_timer_timeout() -> void:
	start_count += 1
	game_time.emit(start_count)
