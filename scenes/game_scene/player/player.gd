extends Area2D
class_name Player

var movement_distance : int = 80
const INPUTS : Dictionary[String, Vector2]= { "move_up" : Vector2.UP, "move_right" : Vector2.RIGHT, "move_left" : Vector2.LEFT, "move_down" : Vector2.DOWN }
const UNMOVED_INPUTS : Dictionary[String, Vector2]= { "move_up" : Vector2.UP, "move_down" : Vector2.DOWN }

var animation_speed : float = 0.25
var is_moving : bool = false
var centre : Vector2 = Vector2(movement_distance, movement_distance)
var has_moved: bool = false
var bounds : Vector2 = Vector2.ZERO
var current_position_in_grid : Vector2 = Vector2.ZERO
var centre_position_in_grid : Vector2 = Vector2.ZERO
var starting_position : Vector2 = Vector2.ZERO
var controls_enabled : bool = true

signal level_completed
signal new_centre_position(position: Vector2)

func set_starting_position(movement_distance: int, grid_size: Vector2, starting_position: Vector2, tile_size: int) -> void:
	has_moved = false
	centre = starting_position
	self.starting_position = starting_position
	self.movement_distance = movement_distance
	position = centre
	bounds = grid_size
	var ratio = tile_size / 80.0
	scale = Vector2(ratio, ratio)

func is_movement_possible(key: Vector2) -> bool:
	if has_moved:
		match (key):
			Vector2.UP: return centre_position_in_grid.y > 0 and current_position_in_grid.y != 0
			Vector2.DOWN: return centre_position_in_grid.y < bounds.y - 1 and current_position_in_grid.y < bounds.y - 1
			Vector2.RIGHT: return centre_position_in_grid.x < bounds.x - 1 and current_position_in_grid.x < bounds.x - 1
			Vector2.LEFT: return centre_position_in_grid.x > 0 and current_position_in_grid.x != 0
			_: return false
	else:
		match (key):
			Vector2.UP: return current_position_in_grid.y > 0
			Vector2.DOWN: return current_position_in_grid.y < bounds.y - 1
			_: return false

func move_position(key: Vector2) -> void:
	if has_moved:
		current_position_in_grid = centre_position_in_grid + key
	else:
		current_position_in_grid += key

func handle_movement_key(event: InputEvent, keys: Dictionary[String, Vector2]) -> void:
	for key in keys.keys():
		if not is_moving and event.is_action_pressed(key) and is_movement_possible(keys[key]):
			move_position(keys[key])
			
			if has_moved:
				_tween_to_new_position(centre + keys[key] * movement_distance)
			else:
				_tween_to_new_position(position + keys[key] * movement_distance)

			_check_if_game_over()
			return

func _tween_to_new_position(new_position) -> void:
	is_moving = false
	var tween = create_tween()
	
	tween.tween_property(self, "position", new_position, animation_speed).set_trans(Tween.TRANS_SINE)
	await tween.finished
	is_moving = false

func _check_if_game_over() -> void:
	if centre_position_in_grid.x == bounds.x - 1:
		print("Level Completed")
		level_completed.emit()
		new_centre_position.emit(centre_position_in_grid + Vector2.RIGHT)
		controls_enabled = true

func _input(event: InputEvent) -> void:
	if controls_enabled:
		if event.is_action_pressed("interact"):
			_move_centre()
			return

		if has_moved:
			handle_movement_key(event, INPUTS)
		else:
			handle_movement_key(event, UNMOVED_INPUTS)

func _move_centre() -> void:
	has_moved = true
	centre = position
	centre_position_in_grid = current_position_in_grid
	new_centre_position.emit(centre_position_in_grid)
	current_position_in_grid = centre_position_in_grid + Vector2.RIGHT
	_tween_to_new_position( centre + movement_distance * Vector2.RIGHT )
	_check_if_game_over()
	# print("Centre 				= %s" % centre)
	# print("Centre Position		= %s" % centre_position_in_grid)
	# print("Translated Centre 	= %s" % (starting_position + centre_position_in_grid * movement_distance))
