extends Control

enum BuildMode { NONE, MYCEL, TURRET, WALL }
var current_mode = BuildMode.NONE

var money = 500

const MYCEL_COST = 10
const TURRET_COST = 50
const WALL_COST = 20

@onready var mycel_button = $Panel/VBoxContainer/MycelButton
@onready var turret_button = $Panel/VBoxContainer/TurretButton
@onready var wall_button = $Panel/VBoxContainer/WallButton
@onready var money_label = $Panel/VBoxContainer/MoneyLabel

func _ready():
	update_money_label()
	
func _process(delta):
	if Input.is_action_just_pressed("deselect_build"):
		current_mode = BuildMode.NONE

func _on_mycel_button_pressed() -> void:
	current_mode = BuildMode.MYCEL

func _on_turret_button_pressed() -> void:
	current_mode = BuildMode.TURRET
	
func _on_wall_button_pressed():
	current_mode = BuildMode.WALL

func get_current_mode() -> BuildMode:
	return current_mode

func update_money_label() -> void:
	money_label.text = "Money: " + str(money)

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


