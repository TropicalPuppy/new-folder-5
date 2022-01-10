extends CanvasLayer

onready var hud = $Control/HUD
onready var pause_ui = $Control/PauseUI
onready var game_over_ui = $Control/GameOver

func _ready():
	hud.visible = true
	pause_ui.visible = false
	game_over_ui.visible = false

func call_menu():
	pause_ui.open()

func call_game_over():
	game_over_ui.open()

func _process(_delta):
	$Modal.visible = get_tree().paused or game_over_ui.visible
