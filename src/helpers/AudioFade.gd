extends AudioStreamPlayer

onready var tween_in = $TweenIn
onready var tween_out = $TweenOut

export(float) var duration = 1.00
export(bool) var fade_in_automatically = true

func fade_out():
	tween_out.interpolate_property(self, "volume_db", 0, -80, duration, Tween.EASE_IN, 0)
	tween_out.start()
	
func fade_in(from_position: float = 0.0):
	tween_in.interpolate_property(self, "volume_db", -80, 0, duration, Tween.EASE_IN, 0)
	tween_in.start()
	.play(from_position)

func play(from_position: float = 0.0) -> void:
	if fade_in_automatically:
		fade_in()
	else:
		.play(from_position)

func _ready():
	if autoplay and fade_in_automatically:
		fade_in(0)
