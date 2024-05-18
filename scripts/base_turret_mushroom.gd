extends StaticBody2D

@export var health: int = 50
@export var missile_scene: PackedScene
@export var fire_rate: float = 2.0

@onready var reload_timer = $ReloadTimer
@onready var launch_timer = $LaunchTimer
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

var target: CharacterBody2D = null
var enemies_in_range: Array = []

func _ready() -> void:
	add_to_group("mushrooms")
	reload_timer.wait_time = fire_rate
	reload_timer.start()

func _process(delta: float) -> void:
	if enemies_in_range.size() == 0:
		animated_sprite.play("idle")
	update_target()
	
func update_target() -> void:
	var closest_distance = INF
	target = null
	for enemy in enemies_in_range:
		if enemy != null and enemy.is_alive():
			var distance = global_position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				target = enemy
		else:
			enemies_in_range.erase(enemy)

func _on_attack_area_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("take_damage") and body.has_method("is_alive"):
		enemies_in_range.append(body)

func _on_attack_area_body_exited(body: Node) -> void:
	enemies_in_range.erase(body)

func _on_reload_timer_timeout() -> void:
	if target != null:
		animation_player.play("launch")

func launch_missile() -> void:
	var missile = missile_scene.instantiate()
	missile.global_position = global_position
	missile.set_target(target)
	get_parent().add_child(missile)
	
func launch_animation() -> void:
	animated_sprite.play("attack")

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	remove_from_group("mushrooms")
	queue_free()
	
