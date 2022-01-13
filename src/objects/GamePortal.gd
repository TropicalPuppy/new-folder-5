extends Area2D

export(String) var map_name = ''
export(float) var x = 0
export(float) var y = 0
export(bool) var auto_fade = true
export(float) var fade_duration = 1.0

func _ready():
	assert(map_name != '', "ERROR: Portal (" + name + ") has no target map")

func _on_GamePortal_body_entered(body):
	if body.name != "GamePlayer":
		return
		
	if Game.is_transferring:
		return

	if auto_fade:
		Game.fade_and_teleport(map_name, x, y, fade_duration)
	else:
		Game.teleport_player(map_name, x, y)
