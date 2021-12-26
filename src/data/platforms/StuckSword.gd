class_name StuckSword
extends KinematicBody2D


func set_direction(direction):
	$Sprite.scale.x = direction
	$CollisionShape2D.position.x = -3 * direction

func set_quick_destroy(value):
	if value:
		$Timer.wait_time = 0.5
	else:
		$Timer.wait_time = 4

func _on_Timer_timeout():
	call_deferred("queue_free")
