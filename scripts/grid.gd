extends Node2D

@export var grid_size: int = 32
@export var mycel_scene: PackedScene = preload("res://scenes/mycel.tscn")
@export var base_turret_mushroom_scene: PackedScene = preload("res://scenes/base_turret_mushroom.tscn")

var grid_map = {}

func _ready() -> void:
	initialize_grid()
	var center_pos = Vector2(0, 0)
	for x in range(-1, 2):
		for y in range(-1, 2):
			var mycel_pos = center_pos + Vector2(x, y)
			var initial_mycel = mycel_scene.instantiate()
			place_object(mycel_pos, initial_mycel)

func initialize_grid() -> void:
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
		print("Placed object at: ", grid_pos)
	else:
		print("Position already occupied: ", grid_pos)

func can_place_mycel(grid_pos: Vector2) -> bool:
	if is_occupied(grid_pos):
		print("Grid position is occupied: ", grid_pos)
		return false
	var neighbors = [
		grid_pos + Vector2(1, 0),
		grid_pos + Vector2(-1, 0),
		grid_pos + Vector2(0, 1),
		grid_pos + Vector2(0, -1)
	]
	for neighbor in neighbors:
		if is_occupied(neighbor) and grid_map[neighbor].get_script() == mycel_scene.get_script():
			print("Can place mycel at: ", grid_pos, " Neighbor: ", neighbor)
			return true
	print("Cannot place mycel at: ", grid_pos)
	return false

func place_mycel(grid_pos: Vector2) -> void:
	if can_place_mycel(grid_pos):
		var mycel = mycel_scene.instantiate()
		place_object(grid_pos, mycel)
	else:
		print("Failed to place mycel at: ", grid_pos)

func can_place_turret_mushroom(grid_pos: Vector2) -> bool:
	if is_occupied(grid_pos):
		print("Grid position is occupied: ", grid_pos)
		return false
	var neighbors = [
		grid_pos + Vector2(1, 0),
		grid_pos + Vector2(-1, 0),
		grid_pos + Vector2(0, 1),
		grid_pos + Vector2(0, -1)
	]
	for neighbor in neighbors:
		if is_occupied(neighbor) and grid_map[neighbor].get_script() == mycel_scene.get_script():
			print("Can place turret mushroom at: ", grid_pos, " Neighbor: ", neighbor)
			return true
	print("Cannot place turret mushroom at: ", grid_pos)
	return false

func place_turret_mushroom(grid_pos: Vector2, turret_mushroom_scene: PackedScene) -> void:
	if can_place_turret_mushroom(grid_pos):
		var turret_mushroom = turret_mushroom_scene.instantiate()
		place_object(grid_pos, turret_mushroom)
	else:
		print("Failed to place turret mushroom at: ", grid_pos)
