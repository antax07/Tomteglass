extends CharacterBody2D

@export var speed: float = 150.0
@export var curve_height_multiplier: float = 1.0
@export var attack_damage: int = 25

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D

var target: CharacterBody2D = null
var start_position: Vector2
var launch_direction: Vector2
var travel_distance: float
var elapsed_time: float = 0.0	
var total_time: float
var previous_position: Vector2

func set_target(target: CharacterBody2D) -> void:
	if target == null:
		queue_free()
		return
	
	self.target = target
	self.start_position = global_position
	self.previous_position = start_position
	self.launch_direction = Vector2(0, 1)
	
	# Check if target is valid
	if target != null:
		self.travel_distance = start_position.distance_to(target.global_position)
		self.total_time = travel_distance / speed
	else:
		queue_free()

func get_rotation_angle(position: Vector2, velocity: Vector2) -> float:
	var angle_radians = atan2(velocity.y, velocity.x)
	return angle_radians
	
func hit_animation() -> void:
	animated_sprite.play("explosion")

func _process(delta: float) -> void:
	if target != null:
		elapsed_time += delta
		var t = elapsed_time / total_time
		if t > 1:
			t = 1
		
		var remaining_distance = lerp(travel_distance, 0.0, t)
		var dynamic_curve_height = curve_height_multiplier * remaining_distance
		
		var current_x = lerp(start_position.x, target.global_position.x, t)
		var current_y = lerp(start_position.y, target.global_position.y, t) - dynamic_curve_height * (4 * t * (1 - t))
		var current_position = Vector2(current_x, current_y)
		
		var velocity = (current_position - previous_position) / delta
		rotation = get_rotation_angle(current_position, velocity)
		
		global_position = current_position
		previous_position = current_position
		
		if t >= 0.95:
			if target.has_method("take_damage"):
				target.take_damage(attack_damage)
				attack_damage = 0 
				animation_player.play("explosion")
	else:
		if animated_sprite.animation != "explosion":
			animation_player.play("explosion")
		if animation_player.get_current_animation_length() <= animation_player.get_current_animation_position():
			queue_free()
