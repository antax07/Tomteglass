extends Control

enum BuildMode { NONE, MYCEL, TURRET, WALL, REMOVE }
var current_mode = BuildMode.NONE

var money = 120

const MYCEL_COST = 10
const TURRET_COST = 40
const WALL_COST = 20

@onready var turret_button = $Panel/VBoxContainer/TurretButton
@onready var wall_button = $Panel/VBoxContainer/WallButton
@onready var remove_button = $Panel/VBoxContainer/RemoveButton
@onready var money_label = $Panel/VBoxContainer/Panel2/MoneyLabel
@onready var texture_progress_bar = $Panel/VBoxContainer/HealthBar
@onready var label = $Panel2/Label

var player_mushroom = null
var start_health = 0

func _ready():
	update_money_label()
	var main_node = get_node("/root/Main")
	player_mushroom = main_node.get_node("Player Mushroom")
	start_health = player_mushroom.health
	
func _process(delta):
	if Input.is_action_just_pressed("deselect_build"):
		current_mode = BuildMode.NONE
	texture_progress_bar.value = float(player_mushroom.health) / float(start_health) * 100
	var main_node = get_node("/root/Main")
	var wave_manager = main_node.get_node("Wave Manager")
	label.text = "Score: " + str(wave_manager.current_wave)

func _on_turret_button_pressed() -> void:
	current_mode = BuildMode.TURRET
	
func _on_wall_button_pressed() -> void:
	current_mode = BuildMode.WALL
	
func _on_remove_button_pressed() -> void:
	current_mode = BuildMode.REMOVE

func get_current_mode() -> BuildMode:
	return current_mode

func update_money_label() -> void:
	money_label.text = "Mycel: " + str(money)

func add_money(amount: int) -> void:
	money += amount
	update_money_label()

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		update_money_label()
		return true
	else:
		return false


func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
