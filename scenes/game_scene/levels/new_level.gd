extends Node2D

@export var min_distance_for_player := 128
@export var starting_position := Vector2(256, 256)
@onready var tile_manager: Node2D = $"Tile Manager"
@onready var player: Area2D = $Player


func _ready() -> void:
	player.position = starting_position
	tile_manager.position = starting_position
