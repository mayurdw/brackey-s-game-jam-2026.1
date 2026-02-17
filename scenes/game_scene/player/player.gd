extends Area2D

# TODO: This needs to come from the level manager
var movement_distance : int = 80
const INPUTS : Dictionary[String, Vector2]= { "move_up" : Vector2.UP, "move_right" : Vector2.RIGHT, "move_left" : Vector2.LEFT, "move_down" : Vector2.DOWN }
const UNMOVED_INPUTS : Dictionary[String, Vector2]= { "move_up" : Vector2.UP, "move_down" : Vector2.DOWN }

var animation_speed : float = 0.25
var is_moving : bool = false
var centre : Vector2 = Vector2(movement_distance, movement_distance)
var has_moved: bool = false

func set_starting_position(movement_distance: int, grid_size: Vector2, centre: Vector2) -> void:
	has_moved = false
	centre = centre
	position = centre

func handle_movement_key(event: InputEvent, keys: Dictionary[String, Vector2]) -> void:
	for key in keys.keys():
		if event.is_action_pressed(key) and not is_moving:
			_move(key)
			return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_move_centre()
		return

	handle_movement_key(event, INPUTS if has_moved else UNMOVED_INPUTS)

func _move_centre() -> void:
	has_moved = true
	centre = position
	position = centre + movement_distance * Vector2.RIGHT

func _move(key: String) -> void:
	is_moving = true
	var tween = create_tween()
	tween.tween_property(self, "position", 
		centre + INPUTS[key] * movement_distance, animation_speed).set_trans(Tween.TRANS_SINE)
	await tween.finished
	is_moving = false
