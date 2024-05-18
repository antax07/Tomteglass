extends Node

var current_scene: Node = null

func _ready() -> void:

	change_scene("res://scenes/main_menu.tscn")

func change_scene(scene_path: String) -> void:

	if current_scene:
		current_scene.queue_free()
  
	var scene = load(scene_path).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	current_scene = scene
