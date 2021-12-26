extends Node

func _ready() -> void:
	move_to_first_scene()

func move_to_first_scene():
#	Game.teleport_player("Map1", 23, 700)
	Game.teleport_player("Map1", 1200, 470)
	Game.push_scene("Map")
