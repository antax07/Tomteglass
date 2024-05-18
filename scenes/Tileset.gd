extends Node2D

@onready var tilemap = $TileMap
const ICBM_svamp_ID = 1
var svamp_layer = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed("place"):
		print('place')
		var mouse_pos = get_global_mouse_position()
		var tile_mouse_pos = tilemap.local_to_map(mouse_pos)
		print(tile_mouse_pos)
		tilemap.set_cell(0, tile_mouse_pos, 0, Vector2i.ZERO, 1)
