extends StaticBody2D

@export var health: int = 250

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D

var alive = true

func _ready() -> void:
	add_to_group("mushrooms")
	
func death_animation() -> void:
	animated_sprite.play("death")

func take_damage(amount: int) -> void:
	print(health)
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	alive = false
	remove_from_group("mushrooms")
	collision_shape_2d.queue_free()
	animation_player.play("death")
