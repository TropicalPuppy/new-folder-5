extends Node
class_name GameScreen

signal trigger_fade_in
signal trigger_fade_out

func fade_in(duration = 1.0):
	emit_signal("trigger_fade_in", duration)

func fade_out(duration = 1.0):
	emit_signal("trigger_fade_out", duration)
