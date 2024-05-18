extends Node

@export var base_enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var strong_enemy_scene: PackedScene
@export var flying_enemy_scene: PackedScene
@export var boss_enemy_scene: PackedScene
@export var initial_wave_delay: float = 10.0
@export var initial_spawn_interval: float = 3.0
@export var initial_wave_size: int = 1
@export var difficulty_increase_interval: float = 60.0
@export var map_size: Vector2 = Vector2(1280, 720)

var current_wave: int = 0
var spawn_timer: float = 0.0
var wave_timer: float = 0.0
var difficulty_timer: float = 0.0
var spawn_interval: float
var wave_size: int
var difficulty_level: int = 1

func _ready() -> void:
	spawn_interval = initial_spawn_interval
	wave_size = initial_wave_size
	start_next_wave()

func _process(delta: float) -> void:
	wave_timer -= delta
	difficulty_timer += delta

	if wave_timer <= 0:
		start_next_wave()

	if difficulty_timer >= difficulty_increase_interval:
		increase_difficulty()
		difficulty_timer = 0

func start_next_wave() -> void:
	current_wave += 1
	wave_timer = initial_wave_delay
	spawn_timer = 0.0
	spawn_wave()

func spawn_wave() -> void:
	for i in range(wave_size):
		spawn_timer = spawn_interval * i
		await get_tree().create_timer(spawn_timer).timeout
		spawn_enemy()

func spawn_enemy() -> void:
	var spawn_point = get_random_border_point()
	var enemy_scene = choose_enemy_type()
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.global_position = spawn_point
	get_parent().add_child(enemy_instance)

func get_random_border_point() -> Vector2:
	var edge = randi() % 4
	var x = 0
	var y = 0

	match edge:
		0:  # Top
			x = randf() * map_size.x - map_size.x / 2
			y = -map_size.y / 2
		1:  # Bottom
			x = randf() * map_size.x - map_size.x / 2
			y = map_size.y / 2
		2:  # Left
			x = -map_size.x / 2
			y = randf() * map_size.y - map_size.y / 2
		3:  # Right
			x = map_size.x / 2
			y = randf() * map_size.y - map_size.y / 2

	return Vector2(x, y)

func choose_enemy_type() -> PackedScene:
	var rand = randi() % 100
	if rand < 60:
		return base_enemy_scene
	elif rand < 70:
		return flying_enemy_scene
	elif rand < 80:
		return fast_enemy_scene
	else:
		return strong_enemy_scene

func increase_difficulty() -> void:
	difficulty_level += 1
	wave_size += 1
	spawn_interval = max(1.0, spawn_interval - 0.1)
