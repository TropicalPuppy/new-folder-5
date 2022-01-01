extends MapNode

export(bool) var call_destroy_animation = false
export(String) var item_id = ''
export(String, FILE, "*.wav") var collect_sfx
export(float) var collect_volume = 0.0

signal collected

onready var animation_player = $AnimationPlayer

var CollectSFX = null

func _ready():
	if collect_sfx != '':
		CollectSFX = load(collect_sfx)

func _on_MapCollectible_body_entered(body):
	if not body is GamePlayer:
		return
	
	emit_signal("collected")
	if item_id != '':
		Game.collect_item(item_id)
	
	if collect_sfx != '':
		Game.play_sfx_at(CollectSFX, global_position, collect_volume)
	
	if call_destroy_animation:
		animation_player.play("Destroy")
	else:
		call_deferred("queue_free")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Destroy":
		call_deferred("queue_free")
