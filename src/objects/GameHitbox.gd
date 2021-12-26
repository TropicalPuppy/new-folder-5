class_name GameHitbox
extends Area2D

export(int) var damage = 1;
export(bool) var only_when_falling = false

func disable() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
