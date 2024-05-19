extends StaticBody2D

@onready var animation_player = $AnimatedSprite2D
@onready var sprite_2d = $Sprite2D

@onready var timer = $Timer
const TOP = preload("res://assets/sprites/top.png")
const EDGE = preload("res://assets/sprites/edge.png")

var grid

func _ready() -> void:
	var main_node = get_node("/root/Main")
	grid = main_node.get_node("Test Mycel").get_node("Grid")

func _process(delta: float) -> void:
	if Time.get_ticks_msec() < 4200:
		var current_position = self.position
		var current_grid_pos = grid.world_to_grid(current_position)
		var below_grid_pos = current_grid_pos + Vector2(0, 1)
		if is_within_grid_bounds(below_grid_pos):
			if grid.is_grass(below_grid_pos):
				sprite_2d.texture = TOP
		else:
			sprite_2d.texture = EDGE

func is_within_grid_bounds(grid_pos: Vector2) -> bool:
	return grid_pos in grid.grid_map

func play_grass_animation():
	sprite_2d.texture = EDGE
