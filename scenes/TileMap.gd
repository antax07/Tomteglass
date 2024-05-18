extends Node2D

const  grid_size = 32
var grid = []
var grid_with = 10
var grid_height = 10 

func _ready():
	for x in range(grid_with):
		var column = []
		for y in range(grid_height):
			column.append(false)
		grid.append(column)

func grid_to_world(grid_pos):
	var grid_x = int(global_position.x / grid_size)
	var grid_y = int(global_position.y / grid_size)
	return Vector2(grid_x, grid_y)
	
func place_tower(mouse_pos):
	var grid_pos = grid_to_world(mouse_pos)
	if 
