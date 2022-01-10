extends Control

onready var options = $Options
onready var cursor = $Cursor
onready var try_again_btn = $Options/TryAgain
onready var restart_btn = $Options/Restart
onready var exit_btn = $Options/Exit

enum Options {
	RETRY,
	RESTART,
	EXIT
}

var picked_option = Options.RETRY

func _ready():
	options.visible = true

func _physics_process(_delta):
	if !visible:
		return
	
	cursor.visible = true
	
	if exit_btn.has_focus():
		cursor.position = Vector2(0, 80)
	elif restart_btn.has_focus():
		cursor.position = Vector2(0, 64)
	else:
		cursor.position = Vector2(0, 48)
		if !try_again_btn.has_focus():
			try_again_btn.grab_focus()

func open():
	call_deferred("show")

func show():
	visible = true
	options.visible = true

func close():
	visible = false	

func confirm_exit():
	Game.change_scene("Title")

func confirm_option():
	match picked_option:
		Options.RETRY:
			retry()
		Options.RESTART:
			restart()
		Options.EXIT:
			confirm_exit()
	
	close()
	
func _on_Exit_pressed():
	select_option(Options.EXIT)

func retry():
	Game.restore_checkpoint()

func restart():
	Game.reset()

func select_option(option):
	options.visible = false
	picked_option = option
	
	confirm_option()

func _on_Restart_pressed():
	select_option(Options.RESTART)

func _on_TryAgain_pressed():
	select_option(Options.RETRY)
