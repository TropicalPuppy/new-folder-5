class_name GameBullet
extends KinematicBody2D

onready var collision_shape = $CollisionShape2D
onready var animation_player = $AnimationPlayer

export(bool) var destroyed_by_sword = false
export(int) var direction = 1
export(float) var velocity = 500.0
export(int) var damage = 10
export(String, FILE, "*.tscn,*.scn") var explosion_effect

export(String, FILE, "*.tscn,*.scn") var debris_left
export(String, FILE, "*.tscn,*.scn") var debris_center
export(String, FILE, "*.tscn,*.scn") var debris_right

#onready var animation_player = $AnimationPlayer
var ExplosionScene = null
var DebrisLeft = null
var DebrisCenter = null
var DebrisRight = null
var shooter = null
var created_debris = false

func _ready():
	if explosion_effect != '':
		ExplosionScene = load(explosion_effect)
	if debris_left != '':
		DebrisLeft = load(debris_left)
	if debris_center != '':
		DebrisCenter = load(debris_center)
	if debris_right != '':
		DebrisRight = load(debris_right)

func set_shooter(value):
	shooter = value

func destroy(quietly = false):
	disable(quietly)
	if animation_player.has_animation("Destroy"):
		animation_player.play("Destroy")
	else:
		visible = false
		call_deferred("queue_free")

func disable(quietly = false):
	velocity = 0.0
	collision_shape.disabled = true
	if !quietly:
		create_debris()

func create_debris():
	if created_debris:
		return
		
	created_debris = true
	var debris_strength = damage * 4
	var debris_strength_n = damage * -4
	
	if debris_left != '':
		Game.create_debris(DebrisLeft.instance(), global_position, Vector2(debris_strength_n, debris_strength_n))
	
	if debris_center != '':
		Game.create_debris(DebrisCenter.instance(), global_position, Vector2(0, debris_strength_n))
	
	if debris_right != '':
		Game.create_debris(DebrisRight.instance(), global_position, Vector2(debris_strength, debris_strength_n))

func _physics_process(delta):
	$Sprite.scale.x = direction
	
	var old_shooter_enabled = false
	if shooter != null:
		old_shooter_enabled = shooter.is_collision_enabled()
		shooter.set_collision_enabled(false)
	
	var collision = move_and_collide(Vector2(direction, 0) * velocity * delta)
	
	if shooter != null and old_shooter_enabled:
		shooter.set_collision_enabled(true)
	
	if !collision:
		return
		
	if collision.collider is ThrownSword:
		if destroyed_by_sword:
			explode()
			collision.collider.destroy()
			Game.recall_sword()
		return
	
	explode()
	var hit_direction = 1 if collision.position > collision.collider.global_position else -1

	if collision.collider is GamePlayer:
		if !collision.collider.is_invincible():
			collision.collider.get_hit(hit_direction)
			Game.take_damage(damage)
		else:
			print("Player was invincible")
		return
	
	if collision.collider is GameEnemy:
		collision.collider.get_hit(damage * 2, hit_direction)
		return
		
	if collision.collider is StaticBody2D:
		print("hit the scenario")
		return
		
	print("Hit something")
	print(collision.collider)

func explode():
	if explosion_effect == '':
		destroy()
		return
	
	var effect = ExplosionScene.instance()
	effect.scale.x = scale.x
	effect.global_position = global_position
	effect.connect("animation_finished", self, "queue_free", [], CONNECT_DEFERRED)
	effect.set_as_toplevel(true)
	add_child(effect)

	disable()
	visible = false
	effect.play()

func _on_VisibilityEnabler2D_screen_exited():
	destroy(true)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Destroy":
		visible = false
		call_deferred("queue_free")
		return
