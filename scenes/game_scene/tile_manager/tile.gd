extends Area2D
class_name Tile

@onready var unsafe: Sprite2D = $Unsafe
@onready var safe: Sprite2D = $Safe
@onready var mask: Sprite2D = $Hidden
@onready var timer: Timer = $Timer

var tile_type: int = 0

# tile_type -> 0 = unsafe, 1 = safe, 2 = rewards
func set_data() -> void:
	mask.hide()
	match tile_type:
		0: 
			safe.hide()
			unsafe.show()
		_: 
			safe.show()
			unsafe.hide()

func hide_data() -> void:
	_on_timer_timeout()
	inactivate_tile()

func flash_status() -> void:
	set_data()
	timer.start(1.0)
	activate_tile()

func _on_timer_timeout() -> void:
	safe.hide()
	unsafe.hide()
	mask.show()

func activate_tile() -> void:
	set_modulate(Color(1, 1, 1, 1))

func inactivate_tile() -> void:
	set_modulate(Color(1, 1, 1, 0.5))
