extends Node

func _ready() -> void:
	randomize()
#	yield(get_tree().create_timer(2), "timeout")
	move_to_first_scene()

func move_to_first_scene():
	Game.change_scene("Title")
