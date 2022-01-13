extends CanvasLayer

onready var hud = $Control/HUD
onready var pause_ui = $Control/PauseUI
onready var game_over_ui = $Control/GameOver
onready var fade_control = $FadeControl
onready var fade_tween = $FadeControl/Tween

func _ready():
	hud.visible = true
	pause_ui.visible = false
	game_over_ui.visible = false

func is_fading():
	return fade_tween.is_active()

func call_menu():
	pause_ui.open()

func call_game_over():
	game_over_ui.open()

func _process(_delta):
	$Modal.visible = get_tree().paused or game_over_ui.visible

func fade_in(duration = 1.0):
	fade_to(Color(1.0, 1.0, 1.0, 0.0), duration)

func fade_out(duration = 1.0):
	fade_to(Color(1.0, 1.0, 1.0, 1.0), duration)
	
func fade_to(new_color, duration = 1.0):
	if duration == 0:
		fade_control.modulate = new_color
		return
	
	if fade_control.modulate.is_equal_approx(new_color):
		return
	
	fade_tween.interpolate_property(fade_control, "modulate", fade_control.modulate, new_color, duration, Tween.TRANS_LINEAR)
	fade_tween.start()
