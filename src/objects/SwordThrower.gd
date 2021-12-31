class_name SwordThrower
extends Position2D

const ThrownSword = preload("res://src/data/objects/ThrownSword.tscn")

onready var timer = $Cooldown

func _ready():
	pass

func throw(direction, x_offset = 0.0):
	if not timer.is_stopped():
		return false
	
	var sword = ThrownSword.instance()
	sword.global_position = Vector2(global_position.x + x_offset, global_position.y)
	sword.direction = direction
	sword.set_as_toplevel(true)
	add_child(sword)
	return true
