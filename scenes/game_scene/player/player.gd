extends Area2D

# TODO: This needs to come from the level manager
var movement_distance : int = 80
const INPUTS := { "move_up" : Vector2.UP, "move_right" : Vector2.RIGHT, "move_left" : Vector2.LEFT, "move_down" : Vector2.DOWN }

var animation_speed : float = 0.25
var is_moving : bool = false
var centre : Vector2 = Vector2(movement_distance, movement_distance)

func set_starting_position(movement_distance: int, grid_size: Vector2, centre: Vector2) -> void:
	centre = centre
	position = centre + movement_distance * Vector2.RIGHT

func _input(event: InputEvent) -> void:
	for key in INPUTS.keys():
		if event.is_action_pressed(key) and not is_moving:
			_move(key)
			return
	
	if event.is_action_pressed("interact"):
		_move_centre()

func _move_centre() -> void:
	centre = position
	position = centre + movement_distance * Vector2.RIGHT

func _move(key: String) -> void:
	is_moving = true
	var tween = create_tween()
	tween.tween_property(self, "position", 
		centre + INPUTS[key] * movement_distance, animation_speed).set_trans(Tween.TRANS_SINE)
	await tween.finished
	is_moving = false
