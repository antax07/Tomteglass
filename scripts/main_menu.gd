extends Control


func _on_start_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/main.tscn")

func _on_options_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/options_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
