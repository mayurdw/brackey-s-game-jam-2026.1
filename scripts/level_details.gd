extends Node
class_name LevelDetails

var grid_size : Vector2
var tile_size : int
var inter_tile_gap : int

var gap: int:
	get:
		return tile_size + inter_tile_gap

func _init(level_grid: Vector2, level_tile_size: int, level_inter_tile_gap: int) -> void:
	self.tile_size = level_tile_size
	self.grid_size = level_grid
	self.inter_tile_gap = level_inter_tile_gap
