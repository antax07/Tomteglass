extends Node

@export var base_enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var flying_enemy_scene: PackedScene
@export var strong_enemy_scene: PackedScene
@export var boss_enemy_scene: PackedScene
@export var map_size: Vector2 = Vector2(1280, 720)

@export var base_enemy_health: int = 100
@export var base_enemy_attack: int = 10
@export var fast_enemy_health: int = 75
@export var fast_enemy_attack: int = 15
@export var flying_enemy_health: int = 50
@export var flying_enemy_attack: int = 20
@export var strong_enemy_health: int = 200
@export var strong_enemy_attack: int = 25
@export var boss_enemy_health: int = 1000
@export var boss_enemy_attack: int = 50

@export var waves_between_bosses: int = 10  # Increased to delay boss appearance
@export var wave_interval: float = 10.0  # Time in seconds between waves
@export var min_enemies_per_type: int = 1  # Minimum number of enemies to spawn per type
@export var max_enemies_per_wave: int = 10  # Cap the number of enemies per wave

var current_wave: int = 0
var enemy_types: Array
var active_enemies: Array = []

var first_spawned = false

func _ready():
	print("Game started")
	enemy_types = [
		{ "scene": base_enemy_scene, "health": base_enemy_health, "attack": base_enemy_attack },
		{ "scene": fast_enemy_scene, "health": fast_enemy_health, "attack": fast_enemy_attack },
		{ "scene": flying_enemy_scene, "health": flying_enemy_health, "attack": flying_enemy_attack },
		{ "scene": strong_enemy_scene, "health": strong_enemy_health, "attack": strong_enemy_attack }
	]

	var wave_timer = Timer.new()
	wave_timer.wait_time = wave_interval
	wave_timer.one_shot = false
	add_child(wave_timer)
	
	wave_timer.start()
	print("Wave timer started with interval: ", wave_interval)
	start_next_wave()

func _process(delta):
	for i in range(active_enemies.size() - 1, -1, -1):
		if active_enemies[i] == null:
			print("Removing null enemy at index: ", i)
			active_enemies.remove_at(i)
	print("Active enemies count: ", active_enemies.size())

func start_next_wave():
	current_wave += 1
	print("Starting wave: ", current_wave)
	var num_bosses = max(1, int(current_wave / waves_between_bosses))
	var enemy_pool = []

	if current_wave % waves_between_bosses == 0:
		print("Spawning boss wave with ", num_bosses, " bosses")
		for i in range(num_bosses):
			var boss_instance = boss_enemy_scene.instantiate()
			boss_instance.health = boss_enemy_health + (current_wave * 50)
			boss_instance.attack_damage = boss_enemy_attack + (current_wave * 5)
			print("Boss instance - Health: ", boss_instance.health, " Attack: ", boss_instance.attack_damage)
			enemy_pool.append(boss_instance)
	else:
		print("Spawning regular wave")
		var wave_strength = current_wave * 5  # Reduce scaling factor
		for enemy_type in get_available_enemy_types():
			var calculated_spawn = int(wave_strength / (enemy_type["health"] + enemy_type["attack"]))
			var num_to_spawn = max(min_enemies_per_type, min(max_enemies_per_wave, calculated_spawn))
			print("Calculated number to spawn: ", calculated_spawn)
			print("Adjusted number to spawn: ", num_to_spawn, " enemies of type ", enemy_type["scene"])
			for i in range(num_to_spawn):
				var enemy_instance = enemy_type["scene"].instantiate()
				enemy_instance.health = enemy_type["health"] + (current_wave * 5)
				enemy_instance.attack_damage = enemy_type["attack"] + (current_wave * 1)
				print("Enemy instance - Health: ", enemy_instance.health, " Attack: ", enemy_instance.attack_damage)
				enemy_pool.append(enemy_instance)

	spawn_enemies(enemy_pool)

func get_available_enemy_types() -> Array:
	var available_enemies = []
	if current_wave >= 20:
		available_enemies.append(enemy_types[3])  # strong_enemy_scene
	if current_wave >= 15:
		available_enemies.append(enemy_types[2])  # flying_enemy_scene
	if current_wave >= 10:
		available_enemies.append(enemy_types[1])  # fast_enemy_scene
	available_enemies.append(enemy_types[0])  # base_enemy_scene always available
	return available_enemies

func spawn_enemies(enemy_pool):
	for enemy in enemy_pool:
		var spawn_position = get_random_border_position()
		print("Spawning enemy at position: ", spawn_position)
		enemy.global_position = spawn_position
		add_child(enemy)
		active_enemies.append(enemy)
		
		# Cheat to immediately delete the first spawned enemy
		if not first_spawned:
			print("Deleting first spawned enemy")
			enemy.queue_free()
			active_enemies.pop_back()
			first_spawned = true

func _on_wave_timer_timeout():
	print("Wave timer triggered")
	start_next_wave()

func get_random_border_position() -> Vector2:
	var position = Vector2()
	var edge = randi() % 4
	match edge:
		0:
			position.x = randf() * map_size.x
			position.y = 0
		1:
			position.x = randf() * map_size.x
			position.y = map_size.y
		2:
			position.x = 0
			position.y = randf() * map_size.y
		3:
			position.x = map_size.x
			position.y = randf() * map_size.y
	return position
