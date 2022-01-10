class_name GameHurtbox
extends Area2D

var invincible = false
var disabled = false
var ommit = false

signal invincibility_started
signal invincibility_ended

onready var timer = $Timer
onready var collisionShape = $CollisionShape2D

var enemy = null setget set_enemy
func set_enemy(value):
	enemy = value

func start_invincibility(duration: float, ommit_events := false) -> void:
	var total_duration = duration
#	if invincible and timer.time_left > 0:
#		total_duration += timer.time_left
#		ommit = ommit and ommit_events
#	else:
	ommit = ommit_events

	invincible = true
	collisionShape.set_deferred("disabled", true)
	if (!ommit):
		emit_signal("invincibility_started")
	timer.start(total_duration)

func _on_Timer_timeout() -> void:
	if disabled:
		return
	invincible = false
	collisionShape.set_deferred("disabled", false)
	if (!ommit):
		emit_signal("invincibility_ended")

func disable() -> void:
	invincible = true
	disabled = true
	collisionShape.set_deferred("disabled", true)

func reset():
	if !timer.is_stopped():
		timer.stop()
	disabled = false
	invincible = false
	collisionShape.disabled = false
