extends Sprite

onready var animation_player = $AnimationPlayer
onready var player_detection = $PlayerDetectionZone
onready var player_detection2 = $PlayerDetectionZone2
onready var save_position = $SavePosition
onready var audio_player = $AudioStreamPlayer2D

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

	fly()

func _on_PlayerDetectionZone2_player_exited():
	if animation_player.is_playing() and Game.current_life > 0:
		animation_player.play("Default")

func _on_PlayerDetectionZone2_player_entered():
	var pos = get_save_position()
	if Game.last_checkpoint_state == null:
		return
	
	var last_pos = Game.last_checkpoint_state.position
	if last_pos == null:
		return
	
	if last_pos.map == pos.map and last_pos.x == pos.x and last_pos.y == pos.y:
		animation_player.play("Fly")
	
