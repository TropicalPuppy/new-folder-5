extends Area2D

export(String) var map_name = ''
export(float) var x = 0
export(float) var y = 0

func _ready():
	assert(map_name != '', "ERROR: Portal has no target map")

func _on_GamePortal_body_entered(body):
	if body.name != "GamePlayer":
		return

	Game.teleport_player(map_name, x, y)
