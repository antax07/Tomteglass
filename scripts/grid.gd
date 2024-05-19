extends Node2D

@export var grid_size: int = 32
@export var mycel_scene: PackedScene = preload("res://scenes/mycel.tscn")
@export var base_turret_mushroom_scene: PackedScene = preload("res://scenes/base_turret_mushroom.tscn")
@export var wall_mushroom_scene: PackedScene = preload("res://scenes/wall_mushroom.tscn")
@export var obstiacle_grass: PackedScene = preload("res://scenes/grass_obstacle.tscn")
@export var cursor_valid_texture: Texture
@export var cursor_invalid_texture: Texture

@onready var cursor_highlight = $CursorHighlight

const MYCEL_COST = 10
const TURRET_COST = 50
const WALL_COST = 20

var grid_map = {}
var starting_tiles = []

func _ready() -> void:
	initialize_grid()
	cursor_highlight.visible = false

func initialize_grid() -> void:
	var center_free_radius = 2
	for x in range(-20, 21):
		for y in range(-20, 21):
			var grid_pos = Vector2(x, y)
			grid_map[grid_pos] = null

			# Skip placing grass in the 3x2 center area
			if abs(x) <= 1 and y >= -1 and y <= 1:
				continue

			var distance = grid_pos.length()
			var spawn_chance = get_grass_spawn_chance(distance)

			if randf() < spawn_chance:
				place_grass(grid_pos)

func get_grass_spawn_chance(distance: float) -> float:
	if distance <= 1:
		return 0.0
	elif distance <= 3:
		return 0.5
	elif distance <= 4:
		return 0.85
	elif distance <= 5:
		return 0.95
	else:
		return 1.0

func place_grass(grid_pos: Vector2) -> void:
	var grass = obstiacle_grass.instantiate()
	place_object(grid_pos, grass)

func world_to_grid(position: Vector2) -> Vector2:
	return Vector2(floor(position.x / grid_size), floor(position.y / grid_size))

func grid_to_world(grid_pos: Vector2) -> Vector2:
	return grid_pos * grid_size

func is_occupied(grid_pos: Vector2) -> bool:
	if abs(grid_pos.x) <= 1 and grid_pos.y >= -1 and grid_pos.y <= 1:
		return true  # Central 3x2 area is always "occupied"
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
	if not is_mouse_in_ui_area():
		if can_place_mycel(grid_pos):
			var mycel = mycel_scene.instantiate()
			place_object(grid_pos, mycel)

func can_place_turret_mushroom(grid_pos: Vector2) -> bool:
	return not is_occupied(grid_pos)

func place_turret_mushroom(grid_pos: Vector2, turret_mushroom_scene: PackedScene) -> void:
	if not is_mouse_in_ui_area():
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
		valid = can_place_turret_mushroom(grid_pos) and ui.money > TURRET_COST
	elif build_mode == ui.BuildMode.WALL:
		valid = can_place_turret_mushroom(grid_pos) and ui.money > WALL_COST
	elif build_mode == ui.BuildMode.REMOVE:
		valid = is_occupied(grid_pos) and has_sufficient_money_for_removal(grid_pos) and not is_starting_tile(grid_pos)
	else:
		valid = false
	
	if build_mode == 0:
		cursor_highlight.visible = false
	
	cursor_highlight.texture = cursor_valid_texture if valid else cursor_invalid_texture

func has_sufficient_money_for_removal(grid_pos: Vector2) -> bool:
	var obj = grid_map[grid_pos]
	var removal_cost = 20
	
	var main_node = get_node("/root/Main")
	var ui = main_node.get_node("UI")
	return ui.money >= removal_cost

func is_starting_tile(grid_pos: Vector2) -> bool:
	return grid_pos in starting_tiles

func remove_object(grid_pos: Vector2) -> void:
	if not is_mouse_in_ui_area():
		if is_occupied(grid_pos) and not is_starting_tile(grid_pos):
			var obj = grid_map[grid_pos]
			var removal_cost = 20

			var main_node = get_node("/root/Main")
			var ui = main_node.get_node("UI")
			if ui.spend_money(removal_cost):
				var safe_zone_center = Vector2(0, 0)
				var safe_zone_radius = 1
				
				if abs(grid_pos.x - safe_zone_center.x) <= safe_zone_radius and abs(grid_pos.y - safe_zone_center.y) <= safe_zone_radius:
					print("Cannot remove objects within the safety zone.")
					return
				
				var above_pos = grid_pos + Vector2(0, -1)
				if is_grass(above_pos):
					var above_grass = grid_map[above_pos]
					above_grass.play_grass_animation()

				obj.queue_free()
				grid_map[grid_pos] = null

func is_grass(grid_pos: Vector2) -> bool:
	if is_within_grid_bounds(grid_pos) and grid_map[grid_pos] != null:
		
		if "StaticBody2D" in grid_map[grid_pos].name:
			#print(grid_map[grid_pos].name)
			return true
	return false

func is_within_grid_bounds(grid_pos: Vector2) -> bool:
	return grid_pos in grid_map

func is_mouse_in_ui_area() -> bool:
	var mouse_pos = get_global_mouse_position()
	return mouse_pos.x >= -500 and mouse_pos.x <= -270 and mouse_pos.y >= -280 and mouse_pos.y <= -80
