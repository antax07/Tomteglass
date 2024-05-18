extends "res://scripts/base_insect.gd"
@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready() -> void:
	speed = 5.0
	attack_damage = 50.0
	health = 250
	

func attack_target() -> void:
	if target != null:
		target.take_damage(attack_damage)
		animated_sprite_2d.play("dame")

func take_damage(amount: int) -> void:
	#animated_sprite_2d.play("hurt")
	health -= amount
	if health <= 0:
		die()
