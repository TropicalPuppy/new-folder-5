extends RigidBody2D

func _on_Timer_timeout():
	call_deferred("queue_free")
