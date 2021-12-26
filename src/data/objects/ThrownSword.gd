class_name ThrownSword
extends KinematicBody2D

onready var timer = $Timer

export(int) var direction = 1
export(float) var velocity = 500.0

#onready var animation_player = $AnimationPlayer

func disable():
	if !timer.is_stopped():
		timer.stop()

	velocity = 0.0
	visible = false
	$CollisionShape2D.disabled = true
	collision_mask = 0

func destroy():
	disable()
	call_deferred("queue_free")

func _physics_process(delta):
	$Sprite.scale.x = direction
	var collision = move_and_collide(Vector2(direction, 0) * velocity * delta)
	if !collision:
		return
	
	if collision.collider is StaticBody2D:
		Game.create_stuck_sword(collision.position, direction)
		destroy()
		return
	
	if collision.collider is GameEnemy and collision.collider.is_invincible():
		Game.create_stuck_sword(collision.position, direction, true)
		destroy()
		return

	Game.recall_sword()
	destroy()

	if collision.collider is GameEnemy:
		var hit_direction = 1 if collision.position > collision.collider.global_position else -1
		collision.collider.get_hit(10, hit_direction)
		return

	if collision.collider is KinematicBody2D:
		if "destroyed_by_sword" in collision.collider:
			collision.collider.explode()
			return

		print("sword hit some kinematic body")
		print(collision.collider)
		return
	

func _on_Timer_timeout():
	Game.recall_sword()
	destroy()
