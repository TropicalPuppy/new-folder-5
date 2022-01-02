extends Control

export(int) var value = 0 setget set_value

func set_value(new_value):
	value = new_value
	$Label.text = String(new_value)

func _ready():
	$Label.text = String(value)

func _on_AnimationPlayer_animation_finished(_anim_name):
	call_deferred("queue_free")
