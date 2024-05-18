extends CharacterBody2D

@export var speed: float = 10.0
@export var health: int = 100
@export var attack_damage: int = 10
@export var attack_interval: float = 1.0

var target: StaticBody2D = null
var attack_timer: float = 0.0

func _physics_process(delta: float) -> void:
	if target != null:
		velocity = (target.global_position - global_position).normalized() * speed
		var direction = (target.global_position - global_position).normalized()
		move_and_slide()
		rotation = direction.angle()
		attack_timer -= delta
		if attack_timer <= 0 and global_position.distance_to(target.global_position) < 20:
			attack_timer = attack_interval
			attack_target()
	else:
		find_nearest_mushroom()
		
func find_nearest_mushroom() -> void:
	var mushrooms = get_tree().get_nodes_in_group("mushrooms")
	var closest_distance = INF
	for mushroom in mushrooms:
		var distance = global_position.distance_to(mushroom.global_position)
		if distance < closest_distance:
			closest_distance = distance
			target = mushroom
			
func attack_target() -> void:
	if target != null:
		target.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	queue_free()
