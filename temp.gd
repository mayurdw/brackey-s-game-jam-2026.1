extends Node2D

@export var rows: int = 4
@export var columns: int = 4
@export var traps: Array[String] = []

@onready var selector: Sprite2D = $"Trap Zone/Selector"
@onready var character: Sprite2D = $Character

var animation_speed : float = 0.25
var is_moving : bool = false
var has_moved : bool = false
var centre_position_in_grid : Vector2 = Vector2.ZERO
var selector_position : Vector2 = Vector2.ZERO
# TODO: Change this later
var controls_enabled : bool = true

signal level_completed

const INPUTS : Dictionary[String, Vector2]= { "move_up" : Vector2.UP, "move_right" : Vector2.RIGHT, "move_left" : Vector2.LEFT, "move_down" : Vector2.DOWN }
const UNMOVED_INPUTS : Dictionary[String, Vector2]= { "move_up" : Vector2.UP, "move_down" : Vector2.DOWN }

func _game_over_movement() -> void:
	pass

func _trigger_character_movement() -> void:
	controls_enabled = false
	if traps.has(_get_name()):
		_game_over_movement()
	else:
		var tween = create_tween()
		tween.tween_property(character, "position", selector.global_position, animation_speed).set_trans(Tween.TRANS_SINE)
		await tween.finished
		controls_enabled = true

func _move_centre() -> void:
	has_moved = true
	if is_movement_possible(Vector2.RIGHT):
		selector_position += Vector2.RIGHT
		_tween_to_new_position()
		_trigger_character_movement()
	else:
		level_completed.emit()

func is_movement_possible(key: Vector2) -> bool:
	if has_moved:
		match ( key ):
			Vector2.UP: return centre_position_in_grid.y > 0 and selector_position.y != 0
			Vector2.DOWN: return centre_position_in_grid.y < rows - 1 and selector_position.y < rows - 1
			Vector2.RIGHT: return centre_position_in_grid.x < columns - 1 and selector_position.x < columns - 1
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

func _get_name() -> String:
	return "Trap Zone/%d%d" % [selector_position.y, selector_position.x]

func _tween_to_new_position() -> void:
	var tween = create_tween()
	var target_position = get_node(_get_name()).position

	is_moving = true
	print("Selector %s, position = %s" % [selector, selector_position])
	tween.tween_property(selector, "position", target_position, animation_speed).set_trans(Tween.TRANS_SINE)
	await tween.finished
	print("Selector %s, position = %s" % [selector, selector_position])
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
