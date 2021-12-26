class_name GameGun
extends Node2D

onready var player_detection = $PlayerDetectionZone
onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
onready var bullet_spawn_point = $BulletSpawnPoint
onready var cooldown = $Cooldown

export(String, FILE, "*.tscn,*.scn") var bullet

onready var BulletScene = load(bullet)

enum State {
	IDLE,
	HIT
}

var state = State.IDLE

func _ready():
	pass

func _physics_process(delta):
	match state:
		State.IDLE:
			idle_state(delta)
		State.HIT:
			pass

func idle_state(_delta):
	if not cooldown.is_stopped():
		return
	
	if player_detection.can_see_player():
		fire()
		return
	
func fire():
	cooldown.start()
	animation_player.play("Fire")

func create_bullet():
	var spawn = BulletScene.instance()
	spawn.global_position = bullet_spawn_point.global_position
	spawn.direction = scale.x
	spawn.set_as_toplevel(true)
	add_child(spawn)
	return true
	
