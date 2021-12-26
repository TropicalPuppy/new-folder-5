extends GameEnemyGun

onready var large_player_detection = $Data/PlayerDetectionZone2
onready var direction_timer = $DirectionTimer
var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func face_player():
	if !large_player_detection.can_see_player():
		return
	
	var player = large_player_detection.get_player()
	var difference = abs(player.position.x - position.x)
	if difference > 60:
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
	

func idle_state():
	if is_open:
		pass
	else:
		if large_player_detection.can_see_player():
			face_player()
#		else:
#			open()
	
	#If opening, skip regular idle state
	if animation_player.is_playing() and animation_player.current_animation == "Open":
		return
	
	.idle_state()

func open():
	print("open")
	is_open = true
	animation_player.play("Open")

func get_new_animation():
	var animation = .get_new_animation()
	if animation == "Idle" and is_open:
		return "IdleOpen"
	
	return animation
