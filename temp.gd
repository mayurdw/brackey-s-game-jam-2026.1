extends Node2D

@export var rows: int = 4
@export var columns: int = 4
@export var traps: Array[String] = []
@export var start_time: int = 3

@onready var selector: Sprite2D = $"Trap Zone/Selector"
@onready var character: Sprite2D = $Character
@onready var blood: GPUParticles2D = $Character/Blood
@onready var timer: Timer = $Timer
@onready var end_00: Sprite2D = $"End 00"
@onready var end_01: Sprite2D = $"End 01"
@onready var end_02: Sprite2D = $"End 02"
@onready var end_03: Sprite2D = $"End 03"
@onready var other_character: Node2D = $"Other Character"

var animation_speed : float = 0.25
var is_moving : bool = false
var has_moved : bool = false
var centre_position_in_grid : Vector2 = Vector2.ZERO
var selector_position : Vector2 = Vector2.ZERO
var controls_enabled : bool = true
var active_tiles : Array[Vector2] = []
var game_time : int = 0
var path_tiles : Array[Vector2] = []

signal level_won(level_path: String)
signal level_lost

const INPUTS : Dictionary[String, Vector2]= { "move_up" : Vector2.UP, "move_right" : Vector2.RIGHT, "move_left" : Vector2.LEFT, "move_down" : Vector2.DOWN }
const UNMOVED_INPUTS : Dictionary[String, Vector2]= { "move_up" : Vector2.UP, "move_down" : Vector2.DOWN }

func _ready() -> void:
	controls_enabled = false
	timer.start(1.0)

func _on_timer_timeout() -> void:
	start_time -= 1
	if not start_time > 0:
		controls_enabled = true
		_set_tiles_inactive()
		_set_active_tiles()

func _show_blood_animation() -> void:
	blood.emitting = true

func _game_over_movement() -> void:
	print("Game Over")
	var tween = create_tween()
	tween.tween_property(character, "position", selector.global_position, animation_speed).set_trans(Tween.TRANS_SINE)
	await tween.finished
	_show_blood_animation()
	level_lost.emit()

func _trigger_character_movement() -> void:
	if traps.has(_get_selection_position()):
		_game_over_movement()
	else:
		var tween = create_tween()
		tween.tween_property(character, "position", selector.global_position, animation_speed).set_trans(Tween.TRANS_SINE)
		await tween.finished

func _toggle_tile_status(is_active: bool, grid_position: Vector2) -> void:
	get_node(_get_name(grid_position)).set_modulate(Color(1, 1, 1, 1.0 if is_active else 0.01))

func _set_active_tiles() -> void:
	active_tiles.clear()

	if has_moved:
		for k in INPUTS:
			if (is_movement_possible(INPUTS[k])):
				active_tiles.append(centre_position_in_grid + INPUTS[k])
	else:
		for y in columns:
			active_tiles.append(Vector2(0, y))
	
	active_tiles.append(centre_position_in_grid)
	
	for i in active_tiles:
		_toggle_tile_status(true, i)

func _set_tiles_inactive() -> void:
	for x in rows:
		for y in columns:
			var grid_position = Vector2(x, y)
			if not active_tiles.has(grid_position):
				_toggle_tile_status(false, grid_position)

func _show_other_characters_moving() -> void:
	for i in path_tiles:
		var tween = create_tween()
		tween.tween_property(other_character, "position", i, animation_speed).set_trans(Tween.TRANS_SINE)
		await tween.finished
	level_won.emit()

func _end_of_level_celebrations() -> void:
	controls_enabled = false
	var tween = create_tween()
	var target_position = get_node("End 0%s" % (selector_position.y - 1 as int)).global_position

	tween.tween_property(character, "position", target_position, animation_speed).set_trans(Tween.TRANS_SINE)
	path_tiles.append(target_position - Vector2(16, 0))
	await tween.finished
	_show_other_characters_moving()

func _move_centre() -> void:
	has_moved = true
	if is_movement_possible(Vector2.RIGHT):
		centre_position_in_grid = selector_position
		_trigger_character_movement()
		path_tiles.append(character.global_position)
		selector_position += Vector2.RIGHT
		if is_movement_possible(Vector2.RIGHT):
			_tween_to_new_position()
			_set_active_tiles()
			_set_tiles_inactive()
		else:
			print("Level Completed")
			_end_of_level_celebrations()

func is_movement_possible(key: Vector2) -> bool:
	if has_moved:
		match ( key ):
			Vector2.UP: return centre_position_in_grid.y > 0 and selector_position.y != 0
			Vector2.DOWN: return centre_position_in_grid.y < rows - 1 and selector_position.y <= rows - 1
			Vector2.RIGHT: return centre_position_in_grid.x < columns - 1 and selector_position.x <= columns - 1
			Vector2.LEFT: return centre_position_in_grid.x > 0 and selector_position.x != 0
			_: return false
	else:
		match ( key ):
			Vector2.UP: return selector_position.y > 0
			Vector2.DOWN: return selector_position.y < rows - 1
			_: return false

func _move_position ( key: Vector2 ) -> void:
	if has_moved:
		selector_position = centre_position_in_grid + key
	else:
		selector_position += key

func _get_id(position_in_grid: Vector2) -> String:
	return "%d%d" % [position_in_grid.y, position_in_grid.x]

func _get_selection_position() -> String:
	return _get_id(selector_position)

func _get_name(grid_position: Vector2) -> String:
	return "Trap Zone/%s" % _get_id(grid_position)

func _tween_to_new_position() -> void:
	var tween = create_tween()
	var target_position = get_node(_get_name(selector_position)).position

	is_moving = true
	tween.tween_property(selector, "position", target_position, animation_speed).set_trans(Tween.TRANS_SINE)
	await tween.finished
	is_moving = false

func handle_movement_key(event: InputEvent, key: Dictionary[String, Vector2]) -> void:
	for k in key.keys():
		if not is_moving and event.is_action_pressed(k) and is_movement_possible(key[k]):
			_move_position( key[ k ] )
			_tween_to_new_position()

func _input(event: InputEvent) -> void:
	if not controls_enabled:
		return

	if event.is_action_pressed("interact"):
		_move_centre()
		return

	handle_movement_key(event, INPUTS if has_moved else UNMOVED_INPUTS)
