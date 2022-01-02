extends Node

func _ready() -> void:
	randomize()
	move_to_first_scene()

func move_to_first_scene():
	Game.teleport_player("Island1", 23, 700)
	Game.push_scene("Map")
