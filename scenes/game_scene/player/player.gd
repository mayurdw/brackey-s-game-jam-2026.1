extends Area2D

# TODO: This needs to come from the level manager
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

func set_starting_position(movement_distance: int, grid_size: Vector2, centre: Vector2) -> void:
	has_moved = false
	centre = centre
	position = centre
	bounds = grid_size

func is_movement_possible(key: Vector2) -> bool:
	if has_moved:
		match (key):
			Vector2.UP: return current_position_in_grid.y > 0
			Vector2.DOWN: return current_position_in_grid.y < bounds.y - 1
			Vector2.RIGHT: return (centre_position_in_grid.x >= current_position_in_grid.x and current_position_in_grid.x < bounds.x - 1)
			Vector2.LEFT: return current_position_in_grid.x > 0
			_: return false
	else:
		match (key):
			Vector2.UP: return current_position_in_grid.y > 0
			Vector2.DOWN: return current_position_in_grid.y < bounds.y - 1
			_: return false

func move_position(key: Vector2) -> void:
	match (key):
		Vector2.UP: current_position_in_grid.y -= 1
		Vector2.DOWN: current_position_in_grid.y += 1
		Vector2.RIGHT: current_position_in_grid.x += 1
		Vector2.LEFT: current_position_in_grid.x -= 1

func handle_movement_key(event: InputEvent, keys: Dictionary[String, Vector2]) -> void:
	for key in keys.keys():
		if not is_moving and event.is_action_pressed(key) and is_movement_possible(keys[key]):
			is_moving = true
			var tween = create_tween()
			move_position(keys[key])
			
			if has_moved:
				tween.tween_property(self, "position", centre + keys[key] * movement_distance, animation_speed).set_trans(Tween.TRANS_SINE)
			else:
				tween.tween_property(self, "position", position + keys[key] * movement_distance, animation_speed).set_trans(Tween.TRANS_SINE)

			await tween.finished
			is_moving = false
			return

func _input(event: InputEvent) -> void:
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
	position = centre + movement_distance * Vector2.RIGHT
