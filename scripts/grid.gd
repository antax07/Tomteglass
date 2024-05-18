extends Node2D

@export var grid_size: int = 32
@export var mycel_scene: PackedScene = preload("res://scenes/mycel.tscn")
@export var base_turret_mushroom_scene: PackedScene = preload("res://scenes/base_turret_mushroom.tscn")
@export var cursor_valid_texture: Texture
@export var cursor_invalid_texture: Texture

@onready var cursor_highlight = $CursorHighlight

const MYCEL_COST = 10
const TURRET_COST = 50
const WALL_COST = 20

var grid_map = {}

func _ready() -> void:
	initialize_grid()
	# Placing initial mycel under the player mushroom at the center in a 3x3 area
	var center_pos = Vector2(0, 0)
	for x in range(-1, 2):
		for y in range(-1, 2):
			var mycel_pos = center_pos + Vector2(x, y)
			var initial_mycel = mycel_scene.instantiate()
			place_object(mycel_pos, initial_mycel)
	
	cursor_highlight.visible = false

func initialize_grid() -> void:
	# Initialize the grid with empty tiles
	for x in range(-10, 10):
		for y in range(-10, 10):
			grid_map[Vector2(x, y)] = null

func world_to_grid(position: Vector2) -> Vector2:
	return Vector2(floor(position.x / grid_size), floor(position.y / grid_size))

func grid_to_world(grid_pos: Vector2) -> Vector2:
	return grid_pos * grid_size

func is_occupied(grid_pos: Vector2) -> bool:
	return grid_pos in grid_map and grid_map[grid_pos] != null

func place_object(grid_pos: Vector2, obj: Node2D) -> void:
	if not is_occupied(grid_pos):
		grid_map[grid_pos] = obj
		obj.position = grid_to_world(grid_pos)
		add_child(obj)

func can_place_mycel(grid_pos: Vector2) -> bool:
	if is_occupied(grid_pos):
		return false
	var neighbors = [
		grid_pos + Vector2(1, 0),
		grid_pos + Vector2(-1, 0),
		grid_pos + Vector2(0, 1),
		grid_pos + Vector2(0, -1)
	]
	for neighbor in neighbors:
		if is_occupied(neighbor) and grid_map[neighbor].get_script() == mycel_scene.get_script():
			return true
	return false

func place_mycel(grid_pos: Vector2) -> void:
	if can_place_mycel(grid_pos):
		var mycel = mycel_scene.instantiate()
		place_object(grid_pos, mycel)

func can_place_turret_mushroom(grid_pos: Vector2) -> bool:
	if is_occupied(grid_pos):
		return false
	var neighbors = [
		grid_pos + Vector2(1, 0),
		grid_pos + Vector2(-1, 0),
		grid_pos + Vector2(0, 1),
		grid_pos + Vector2(0, -1)
	]
	for neighbor in neighbors:
		if is_occupied(neighbor) and grid_map[neighbor].get_script() == mycel_scene.get_script():
			return true
	return false

func place_turret_mushroom(grid_pos: Vector2, turret_mushroom_scene: PackedScene) -> void:
	if can_place_turret_mushroom(grid_pos):
		var turret_mushroom = turret_mushroom_scene.instantiate()
		place_object(grid_pos, turret_mushroom)

func update_cursor_highlight(mouse_pos: Vector2, build_mode: int) -> void:
	
	var main_node = get_node("/root/Main")
	var ui = main_node.get_node("UI")
	
	var grid_pos = world_to_grid(mouse_pos + Vector2(16, 16))
	var world_pos = grid_to_world(grid_pos)
	cursor_highlight.position = world_pos
	cursor_highlight.visible = true
	
	var valid = false
	if build_mode == ui.BuildMode.MYCEL:
		valid = can_place_mycel(grid_pos) and ui.money > MYCEL_COST
	elif build_mode == ui.BuildMode.TURRET:
		valid = can_place_turret_mushroom(grid_pos)  and ui.money > TURRET_COST
	elif build_mode == ui.BuildMode.WALL:
		valid = can_place_turret_mushroom(grid_pos)  and ui.money > WALL_COST
	else:
		valid = false
	
	if build_mode == 0:
		cursor_highlight.visible = false
	
	cursor_highlight.texture = cursor_valid_texture if valid else cursor_invalid_texture
