extends GameEnemyGun

onready var player_detection_melee = $Data/PlayerDetectionZoneMelee

func is_open():
	return !$Data/GameHurtbox/CollisionShape2D.disabled

func idle_state():
	if face_player_automatically and player_detection2.can_see_player() and !is_open():
		face_player()

	pick_something_to_do()

func pick_something_to_do():
	if !cooldown.is_stopped():
		return
		
	if is_open():
		maybe_attack()
		return
	
	if player_detection.can_see_player():
		fire()
		return

	open()

func open():
	if player_detection_melee.can_see_player():
		return

	animation_player.play("Open")
	cooldown.start(0.5)

func maybe_attack():
	if !player_detection_melee.can_see_player():
		return

	animation_player.play("Attack")
	cooldown.start(2)

func update_animation():
	if animation_player.is_playing():
		var anim_name = animation_player.current_animation
		if (anim_name == "Attack" or anim_name == "Open") and _state != State.HIT:
			return
	
	.update_animation()

func get_new_animation():
	if _state == State.HIT:
		return "Hit"
		
	if is_open():
		return "IdleOpen"

	return "Idle"
