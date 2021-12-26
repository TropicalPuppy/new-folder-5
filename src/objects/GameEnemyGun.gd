class_name GameEnemyGun
extends GameEnemy

onready var player_detection = $Data/PlayerDetectionZone
onready var bullet_spawn_point = $Data/BulletSpawnPoint
onready var cooldown = $Cooldown

export(String, FILE, "*.tscn,*.scn") var bullet

onready var BulletScene = load(bullet)

func set_direction(direction):
	.set_direction(direction)
	pass

func set_collision_enabled(enabled):
	$CollisionShape2D.disabled = !enabled
func is_collision_enabled():
	return !$CollisionShape2D.disabled

func idle_state():
	if not cooldown.is_stopped():
		return
	
	if player_detection.can_see_player():
		fire()
		return

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
	add_child(spawn)
	return true
	
