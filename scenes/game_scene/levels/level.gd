extends Node

signal level_lost
signal level_won(level_path : String)
@warning_ignore("unused_signal")
signal level_changed(level_path : String)

## Optional path to the next level if using an open world level system.
@export_file("*.tscn") var next_level_path : String
@onready var remaining_timer: Label = $"MarginContainer/Remaining Timer"
@onready var game_timer: Label = $"MarginContainer/VBoxContainer/Game Timer"

var level_state : LevelState

func _on_lose_button_pressed() -> void:
	level_lost.emit()

func _on_win_button_pressed() -> void:
	level_won.emit(next_level_path)

func open_tutorials() -> void:
	%TutorialManager.open_tutorials()
	level_state.tutorial_read = true
	GlobalState.save()

func _ready() -> void:
	level_state = GameState.get_level_state(scene_file_path)
	#%ColorPickerButton.color = level_state.color
	%BackgroundColor.color = level_state.color
	if not level_state.tutorial_read:
		open_tutorials()

func _on_color_picker_button_color_changed(color : Color) -> void:
	%BackgroundColor.color = color
	level_state.color = color
	GlobalState.save()

func _on_tutorial_button_pressed() -> void:
	open_tutorials()


func _on_level_game_time(current_time_in_secs: int) -> void:
	var seconds :int = current_time_in_secs%60
	var minutes :int = (current_time_in_secs/60)%60
	
	#returns a string with the format "HH:MM:SS"
	game_timer.text = "%02d:%02d" % [minutes, seconds]

func _on_level_remaining_start_count(remaining_time: int) -> void:
	remaining_timer.text = "%d" % remaining_time
	if remaining_time <= 0:
		remaining_timer.hide()
