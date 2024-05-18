extends Node

@export var base_enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var strong_enemy_scene: PackedScene

var current_wave: int = 0
var enemies_to_spawn: int = 0
var spawn_timer: float = 0.0
var spawn_interval: float = 1.0

func _ready() -> void:
	start_next_wave()

func _process(delta: float) -> void:
	if enemies_to_spawn > 0:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_timer = spawn_interval
			spawn_enemy()
			enemies_to_spawn -= 1

func start_next_wave() -> void:
	current_wave += 1
	enemies_to_spawn = calculate_enemies_to_spawn(current_wave)
	spawn_timer = spawn_interval

func calculate_enemies_to_spawn(wave: int) -> int:
	if wave <= 5:
		return wave * 5  # Example: 5 enemies in wave 1, 10 in wave 2, etc.
	elif wave > 40:
		return wave * 15  # More enemies in later waves
	else:
		return wave * 10  # Default enemy count

func spawn_enemy() -> void:
	var enemy_scene: PackedScene = choose_enemy_scene(current_wave)
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.global_position = choose_spawn_position()
	enemy_instance.health += current_wave * 10  # Increase health based on wave
	get_parent().add_child(enemy_instance)

func choose_enemy_scene(wave: int) -> PackedScene:
	if wave > 40:
		return strong_enemy_scene
	elif wave > 20:
		return fast_enemy_scene
	else:
		return base_enemy_scene

func choose_spawn_position() -> Vector2:
	# Implement logic to choose a random spawn position
	return Vector2(randf() * 1280, randf() * 720)
