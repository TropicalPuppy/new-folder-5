extends MapNode

export(bool) var call_destroy_animation = false
export(String) var item_id = ''

signal collected

onready var animation_player = $AnimationPlayer

func _ready():
	pass # Replace with function body.

func _on_MapCollectible_body_entered(body):
	if not body is GamePlayer:
		return
	
	emit_signal("collected")
	if item_id != '':
		Game.collect_item(item_id)
	
	if call_destroy_animation:
		animation_player.play("Destroy")
	else:
		call_deferred("queue_free")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Destroy":
		call_deferred("queue_free")
