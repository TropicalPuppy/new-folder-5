extends GameCharacter
class_name GamePlayer

onready var sprite_holder = $SpriteHolder
onready var animation_player = $AnimationPlayer
onready var collision_shape = $CollisionShape2D
onready var data = $Data
onready var interactionRay = $Data/InteractionRayCast
onready var platform_detector = $Data/PlatformDetector
onready var ground_detector = $Data/GroundDetector
onready var hurtbox = $Data/PlayerHurtbox
onready var sword_thrower = $Data/SwordThrower
onready var throw_cooldown = $ThrowCooldown
onready var thrust_cooldown = $ThrustCooldown
onready var back_detector = $Data/BackDetector
onready var front_detector = $Data/FrontDetector
onready var blink_animation = $BlinkAnimationPlayer

const swordLess = preload("res://assets/player/Captain.png")
const swordFull = preload("res://assets/player/CaptainSword.png")

signal run
signal jump
signal fall
signal game_over

# Y speed: 200 - 450

enum State {
	MOVE,
	HIT,
	ATTACK,
	DEAD
}

const FLOOR_DETECT_DISTANCE = 5.0

var state = State.MOVE setget set_state
var show_sword = false setget set_show_sword
var air_slash_disabled = false
var continue_combo = false
var combo_is_thrust = false
var has_double_jumped = false
var was_on_air = false
var current_knockback = Vector2.ZERO
var last_ground = Vector2.ZERO
var last_ground_direction = 1

func _ready() -> void:
	set_show_sword(false)
	reset()
	
	# warning-ignore:return_value_discarded
	Game.connect("update_player_position", self, "update_player_position")
	# warning-ignore:return_value_discarded
	Game.connect("player_died", self, "die")

func set_state(value):
	if state == State.DEAD:
		return
	
	state = value

func get_width():
	var sprite = get_sprite()
	return sprite.texture.get_width()

func update_player_position():
	position.x = Game.player_x
	position.y = Game.player_y

func is_invincible():
	if blink_animation.is_playing() and blink_animation.current_animation == "Start":
		return true
	if state == State.HIT:
		return true
	return false

func update_invincibility_passability():
	set_collision_mask_bit(7, is_invincible() or state == State.DEAD)

func set_show_sword(value):
	show_sword = value
	
	if show_sword:
		get_sprite().set_texture(swordFull)
	else:
		get_sprite().set_texture(swordLess)

func disable_all_hitboxes():
	$Data/Hitboxes/AirSlashHitbox/CollisionShape2D.disabled = true
	$Data/Hitboxes/SlashHitbox/CollisionShape2D.disabled = true
	$Data/Hitboxes/ThrustHitbox/CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	update_sprite()
	update_invincibility_passability()
	update_speed()
	
	match state:
		State.MOVE:
			update_last_ground()
			disable_all_hitboxes()
			move_state(delta)
			check_attack_input()
		State.HIT:
			update_last_ground()
			disable_all_hitboxes()
			hit_state(delta)
		State.ATTACK:
			attack_state(delta)
		State.DEAD:
			dead_state(delta)

func update_speed():
	speed.x = 120 + Game.level
	speed.y = 270 + Game.level * 3

func update_last_ground():
	ground_detector.force_raycast_update()
	if ground_detector.is_colliding():
		last_ground = position
		last_ground_direction = data.scale.x

func update_sprite():
	if !Game.has_sword and Input.is_action_pressed("debug") and Input.is_action_just_pressed("slash"):
		Game.has_sword = true

	var should_show_sword = Game.has_sword and throw_cooldown.is_stopped()
	if show_sword != should_show_sword:
		set_show_sword(should_show_sword)

func apply_velocity(direction: Vector2, is_jump_interrupted: bool) -> void:
	_velocity = .calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform = platform_detector.is_colliding()
	_velocity = move_and_slide_with_snap(_velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false)
	
func increase_fall_speed(delta):
	if state == State.ATTACK:
		return
	
	.increase_fall_speed(delta)

func change_direction(direction):
	if direction == 0:
		return
	
	if direction > 0:
		sprite_holder.scale.x = 1
		data.scale.x = 1
		collision_shape.position.x = -1
	else:
		sprite_holder.scale.x = -1
		data.scale.x = -1
		collision_shape.position.x = 1

func move_state(_delta: float) -> void:
	if was_on_air and is_on_floor():
		fall()
	was_on_air = !is_on_floor()
	set_collision_mask_bit(3, !Input.is_action_pressed("ui_down"))
	
	var direction = get_direction()
	var is_jump_interrupted = Input.is_action_just_released("jump")
	apply_velocity(direction, is_jump_interrupted)

	change_direction(direction.x)
	
	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)

func hit_state(_delta: float) -> void:
	apply_velocity(current_knockback, true)

func dead_state(_delta: float) -> void:
	apply_velocity(current_knockback, true)
	
	if Game.current_life > 0:
		reset()

func attack_state(_delta: float) -> void:
	if !animation_player.is_playing():
		self.state = State.MOVE
		return
		
	apply_velocity(Vector2.ZERO, true)
	var old_anim = animation_player.current_animation
		
	if old_anim == "Throw":
		return
	
	if Input.is_action_just_pressed("slash"):
		if old_anim == "Thrust" or old_anim == "Slash" or old_anim == "AirSlash" or old_anim == "Slash2":
			continue_combo = true
			combo_is_thrust = false
			if is_on_floor():
				Game.add_swing_xp(0.1)
			else:
				Game.add_swing_xp(0.2)
			return

	if Input.is_action_just_pressed("thrust"):
		if old_anim == "Slash" or old_anim == "Slash2":
			continue_combo = true
			combo_is_thrust = true
			Game.add_swing_xp(0.15)
			thrust_cooldown.start()
			return

func check_attack_input():
	if !show_sword:
		return
		
	if air_slash_disabled and is_on_floor():
		air_slash_disabled = false
	
	continue_combo = false
	combo_is_thrust = false
	if Input.is_action_just_pressed("slash"):
		if is_on_floor():
			animation_player.play("Slash")
			self.state = State.ATTACK
			Game.add_swing_xp(0.1)
		elif not air_slash_disabled:
			animation_player.play("AirSlash")
			air_slash_disabled = true
			self.state = State.ATTACK
			_velocity.y = 0
			Game.add_swing_xp(0.2)
		
		return
	
	if thrust_cooldown.is_stopped() and Input.is_action_just_pressed("thrust") and is_on_floor():
		self.state = State.ATTACK
		animation_player.play("Thrust")
		Game.add_swing_xp(0.15)
		thrust_cooldown.start()
		return
	
	if Input.is_action_just_pressed("throw"):
		if !throw_cooldown.is_stopped():
			return

		self.state = State.ATTACK
		animation_player.play("Throw")
		if !is_on_floor():
			_velocity.y = 0
		Game.add_swing_xp(0.05)
		
		return

func can_jump_now():
	if is_on_floor():
		return true
		
	if !has_double_jumped and Game.can_double_jump:
		return true
	
	if Input.is_action_pressed("debug"):
		return true
		
	return false

func get_direction():
	var x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y = 0
	
	if can_jump_now() and Input.is_action_just_pressed("jump"):
		y = -1
		if is_on_floor():
			jump()
			has_double_jumped = false
		else:
			has_double_jumped = true
	
	return Vector2(x, y)

func get_new_animation():
	if animation_player.is_playing() and (animation_player.current_animation == "Hit" or animation_player.current_animation == "FatalHit"):
		return animation_player.current_animation

	if !is_on_floor():
		if _velocity.y >= 0:
			return "Fall"

		return "Jump"

	if abs(_velocity.x) > 0.1:
		return "Walk"
	return "Idle"
	
func check_interactions() -> void:
	if !Input.is_action_just_pressed("interact"):
		return
		
	interactionRay.enabled = true
	interactionRay.force_raycast_update()
	_check_interactions()
	interactionRay.enabled = false

func _check_interactions() -> void:
	if !interactionRay.is_colliding():
		return

	var collider = interactionRay.get_collider()
	if collider != null and collider is MapNode:
		collider.activate()

func mark_as_dead() -> void:
	self.state = State.DEAD
	
#	visible = false
#	queue_free()

func set_camera_path(camera_path: NodePath) -> void:
	$RemoteTransform2D.remote_path = camera_path

func get_sprite():
	return sprite_holder.get_child(0)

func _on_GameHurtbox_invincibility_ended() -> void:
	blink_animation.play("Stop")
	pass

func _on_GameHurtbox_invincibility_started() -> void:
	blink_animation.play("Start")
	pass

func _on_GameHurtbox_area_entered(area: Area2D) -> void:
	if state == State.HIT:
		return
		
	if area is Spike:
		if !is_on_floor():
			get_hit(5)
			return
		
		return
		
	if area is GameHitbox:
		get_hit(area.damage)

func get_hit(damage, direction = 0):
	var max_damage = damage * (101 - Game.level) / 100.0
	var hard_def = 0 if Game.level == 1 else Game.level / 5.0
	var max_def = int(damage / 10.0)
	var def = 0 if max_def == 0 else randi() % max_def
	var real_damage = int(max_damage - def - hard_def)
	
	Game.show_damage(real_damage, global_position, true)
	Game.take_damage(real_damage)
	self.state = State.HIT
	current_knockback = Vector2.ZERO
	change_direction(direction)
	
	if Game.current_life == 0:
		animation_player.play("FatalHit")
	else:
		animation_player.play("Hit")

func _on_AnimationPlayer_animation_started(anim_name: String) -> void:
	if anim_name == "Jump":
		$JumpAudioStreamPlayer.play()
		return

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Hit":
		self.state = State.MOVE
		return
	if anim_name == "FatalHit":
		call_game_over()
		return

	if state == State.ATTACK:
		if continue_combo:
			disable_all_hitboxes()
			continue_combo = false
			match anim_name:
				"Slash":
					if combo_is_thrust:
						animation_player.play("Thrust")
					else:
						animation_player.play("Slash2")
					return
				"Slash2":
					if combo_is_thrust:
						animation_player.play("Thrust")
					else:
						animation_player.play("Slash")
					return
				"Thrust":
					animation_player.play("Slash")
					return
				"AirSlash":
					animation_player.play("AirSlash2")
					return
		
		self.state = State.MOVE
	
func throw_sword():
	back_detector.force_raycast_update()
	front_detector.force_raycast_update()

	var direction = data.scale.x
	var x_offset = 0

	if back_detector.is_colliding():
		x_offset = 6 * direction
	elif front_detector.is_colliding():
		x_offset = -6 * direction

	sword_thrower.throw(direction, x_offset)
	Game.lose_sword()
	throw_cooldown.start(calc_throw_cooldown())

func calc_throw_cooldown():
	var base = 1.2
	var off = floor(Game.level / 2.5) / 10.0
	return base - off

func run():
	emit_signal("run", position, data.scale.x)
	Game.add_walk_xp(0.1)

func jump():
	emit_signal("jump", position, data.scale.x)
	Game.add_jump_xp(0.1)

func fall():
	emit_signal("fall", position, data.scale.x)

func knockback(x, y):
	current_knockback.x = x * data.scale.x
	current_knockback.y = y

func _on_GameHurtbox_body_entered(body):
	if body is GameBullet:
		body.explode()
		body.hit_player(self)

func notify_pit():
	Game.take_damage(5)
	
	if Game.current_life == 0:
		call_game_over()
		return
	
	position = last_ground
	current_knockback = Vector2.ZERO
	change_direction(last_ground_direction)
	hurtbox.start_invincibility(1)
	call_deferred("show_pit_damage", 5)

func show_pit_damage(damage):
	show_damage(damage)

func show_damage(damage):
	Game.show_damage(damage, global_position, true)

func die():
	mark_as_dead()

func call_game_over():
	mark_as_dead()
#	enable_gravity = false
	hurtbox.disable()
	set_collision_layer_bit(0, false)
	emit_signal("game_over")

func reset():
	state = State.MOVE
	current_knockback = Vector2.ZERO
	change_direction(1)
	throw_cooldown.stop()
	thrust_cooldown.stop()
	hurtbox.reset()
	disable_all_hitboxes()
	set_collision_layer_bit(0, true)
	blink_animation.play("Stop")
	
	enable_gravity = true
