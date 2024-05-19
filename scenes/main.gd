extends Node2D

@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var ui = %UI

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_audio_stream_player_2d_finished():
	audio_stream_player_2d.play()


func _on_timer_timeout():
	ui.get_node("Label2")
