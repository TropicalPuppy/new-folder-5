extends Area2D

signal player_entered
signal player_exited

var player = null

func can_see_player() -> bool:
	return player != null

func _on_PlayerDetectionZone_body_entered(body: Node) -> void:
	player = body
	emit_signal("player_entered")

func _on_PlayerDetectionZone_body_exited(_body: Node) -> void:
	player = null
	emit_signal("player_exited")

func get_player():
	return player
