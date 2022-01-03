extends Node

func _ready() -> void:
	randomize()
	move_to_first_scene()

func move_to_first_scene():
	Game.push_scene("Title")
