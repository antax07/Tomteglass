extends Node2D

@onready var grid = $Grid
@onready var camera = %Camera2D
@onready var ui = %UI

const MYCEL_COST = 10
const TURRET_COST = 40
const WALL_COST = 20


func _input(event):
	if event is InputEventMouseMotion:
		var world_pos = camera.get_global_mouse_position()
		grid.update_cursor_highlight(world_pos, ui.get_current_mode())

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos = camera.get_global_mouse_position() + Vector2(16, 16)
		var grid_pos = grid.world_to_grid(world_pos)
		
		var build_mode = ui.get_current_mode()
		if build_mode == ui.BuildMode.MYCEL:
			if grid.can_place_mycel(grid_pos):
				if ui.spend_money(MYCEL_COST):
					grid.place_mycel(grid_pos)
		elif build_mode == ui.BuildMode.TURRET:
			if grid.can_place_turret_mushroom(grid_pos):
				if ui.spend_money(TURRET_COST):
					grid.place_turret_mushroom(grid_pos, preload("res://scenes/base_turret_mushroom.tscn"))
		elif build_mode == ui.BuildMode.REMOVE:
			grid.remove_object(grid_pos)
		elif build_mode == ui.BuildMode.WALL:
			if grid.can_place_turret_mushroom(grid_pos):
				if ui.spend_money(WALL_COST):
					grid.place_turret_mushroom(grid_pos, preload("res://scenes/wall_mushroom.tscn"))

func enemy_killed():
	ui.add_money(20)
