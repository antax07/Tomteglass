extends StaticBody2D

@export var health: int = 200
@export var attack_damage: int = 50
@export var attack_cooldown: float = 1.0

var attack_timer: float = 0.0
var enemies_in_range: Array = []

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("mushrooms")
	
func _process(delta: float) -> void:
	attack_timer -= delta
	if Input.is_action_just_pressed("attack") and attack_timer <= 0:
		perform_attack()

func perform_attack():
	animated_sprite.play("attack")
	attack_timer = attack_cooldown
	for enemey in enemies_in_range:
		if enemey != null:
			enemey.take_damage(attack_damage)
			
func _on_attack_area_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("take_damage"):
		enemies_in_range.append(body)
		
func _on_attack_area_body_exited(body):
	enemies_in_range.erase(body)
	
func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	get_tree().reload_current_scene()


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack" or animated_sprite.animation == "hurt":
		animated_sprite.play("idle")

