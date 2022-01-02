extends CanvasLayer

onready var pause_ui = $Control/PauseUI

func _ready():
	pause_ui.visible = false

func call_menu():
	pause_ui.open()
