extends Area2D

# TODO: This needs to come from the level manager
const MOVEMENT_DISTANCE : int = 128
const INPUTS := { "move_up" : Vector2.UP, "move_right" : Vector2.RIGHT, "move_left" : Vector2.LEFT, "move_down" : Vector2.DOWN }

var animation_speed : float = 0.25
var is_moving : bool = false

func _input(event: InputEvent) -> void:
	for key in INPUTS.keys():
		if event.is_action_pressed(key) and not is_moving:
			_move(key)

func _move(key: String) -> void:
	is_moving = true
	var tween = create_tween()
	tween.tween_property(self, "position", 
		position + INPUTS[key] * MOVEMENT_DISTANCE, animation_speed).set_trans(Tween.TRANS_SINE)
	await tween.finished
	is_moving = false
