extends Node2D

@onready var grid = $Grid
@onready var camera = %Camera2D
@onready var ui = %UI

const MYCEL_COST = 10
const TURRET_COST = 50



func _input(event):
	if event is InputEventMouseMotion:
		var world_pos = camera.get_global_mouse_position()
		grid.update_cursor_highlight(world_pos)

	if event is InputEventMouseButton and event.pressed:
		var world_pos = camera.get_global_mouse_position() + Vector2(16, 16)
		var grid_pos = grid.world_to_grid(world_pos)

		print("Mouse position: ", event.position, " World position: ", world_pos, " Grid position: ", grid_pos)
		
		var build_mode = ui.get_current_mode()
		if build_mode == ui.BuildMode.MYCEL:
			if grid.can_place_mycel(grid_pos):
				if ui.spend_money(MYCEL_COST):
					grid.place_mycel(grid_pos)
				else:
					print("Not enough money to place mycel.")
			else:
				print("Cannot place mycel at: ", grid_pos)
		elif build_mode == ui.BuildMode.TURRET:
			if grid.can_place_turret_mushroom(grid_pos):
				if ui.spend_money(TURRET_COST):
					grid.place_turret_mushroom(grid_pos, preload("res://scenes/base_turret_mushroom.tscn"))
				else:
					print("Not enough money to place turret.")
			else:
				print("Cannot place turret at: ", grid_pos)

func enemy_killed():
	ui.add_money(20)
