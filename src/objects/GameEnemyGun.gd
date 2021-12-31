class_name GameEnemyGun
extends GameEnemy

onready var player_detection = $Data/PlayerDetectionZone
onready var player_detection2 = $Data/PlayerDetectionZone2
onready var bullet_spawn_point = $Data/BulletSpawnPoint
onready var direction_timer = $DirectionTimer
onready var cooldown = $Cooldown

export(String, FILE, "*.tscn,*.scn") var bullet
export(bool) var face_player_automatically = false
export(float) var min_distance_for_quick_turning = 60

onready var BulletScene = load(bullet)

signal create_bullet

#func set_direction(direction):
#	.set_direction(direction)
#	pass

func set_collision_enabled(enabled):
	$CollisionShape2D.disabled = !enabled
func is_collision_enabled():
	return !$CollisionShape2D.disabled

func idle_state():
	if cooldown.is_stopped():
		if player_detection.can_see_player():
			fire()
			return
	
	if face_player_automatically and player_detection2.can_see_player():
		face_player()

func update_animation():
	if animation_player.is_playing() and animation_player.current_animation == "Fire":
		return
	
	.update_animation()
	
func fire():
	cooldown.start()
	animation_player.play("Fire")

func create_bullet():
	var spawn = BulletScene.instance()
	spawn.global_position = bullet_spawn_point.global_position
	spawn.direction = _direction
	spawn.set_shooter(self)
	spawn.set_as_toplevel(true)
	emit_signal("create_bullet", spawn)
	add_child(spawn)
	return true

func face_player():
	if !player_detection2.can_see_player():
		return
	
	var player = player_detection2.get_player()
	var difference = abs(player.position.x - position.x)
	if difference > min_distance_for_quick_turning:
		if player.position.x < position.x:
			set_direction(-1)
		else:
			set_direction(1)
		return
	
	if direction_timer.is_stopped():
		if _direction < 0:
			if player.position.x > bullet_spawn_point.global_position.x:
				set_direction(1)
				direction_timer.start()
		else:
			if player.position.x < bullet_spawn_point.global_position.x:
				set_direction(-1)
				direction_timer.start()
