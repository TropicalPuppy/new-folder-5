extends Sprite

onready var animation_player = $AnimationPlayer
onready var player_detection = $PlayerDetectionZone
onready var player_detection2 = $PlayerDetectionZone2
onready var save_position = $SavePosition
onready var audio_player = $AudioStreamPlayer2D

var player = null

func fly():
	animation_player.play("Fly")
	
	var pos = get_save_position()
	Game.save_checkpoint(pos)
	audio_player.play()

func get_save_position():
	return {
		"map": Game.map_name,
		"x": save_position.global_position.x,
		"y": save_position.global_position.y
	}

func _on_PlayerDetectionZone_player_entered():
	if animation_player.is_playing():
		return

	player = player_detection.get_player()
	fly()

func _on_PlayerDetectionZone2_player_exited():
	if player and animation_player.is_playing() and Game.current_life > 0:
		animation_player.play("Default")
