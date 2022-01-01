extends Area2D

func _on_GamePit_body_entered(body):
	if body.name != "GamePlayer":
		return

	body.notify_pit()
