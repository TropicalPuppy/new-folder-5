class_name SwordThrower
extends Position2D

const ThrownSword = preload("res://src/data/objects/ThrownSword.tscn")

onready var timer = $Cooldown

func _ready():
	pass

func throw(direction):
	if not timer.is_stopped():
		return false
	
	var sword = ThrownSword.instance()
	sword.global_position = global_position
	sword.direction = direction
	sword.set_as_toplevel(true)
	add_child(sword)
	return true
