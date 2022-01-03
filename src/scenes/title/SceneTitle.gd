extends Node2D

onready var start_button = $List/StartButton
onready var options_button = $List/OptionsButton
onready var exit_button = $List/ExitButton
onready var options = $Options
onready var list = $List

func _ready():
	options.visible = false

func _physics_process(_delta):
	start_button.disabled = false
	options_button.disabled = false
	exit_button.disabled = false
	
	if !start_button.has_focus() and !options_button.has_focus() and !exit_button.has_focus():
		start_button.grab_focus()

func _on_StartButton_pressed():
	Game.reset()
	Game.change_scene("Map")

func _on_OptionsButton_pressed():
	start_button.disabled = true
	options_button.disabled = true
	exit_button.disabled = true
	options.open()

func _on_ExitButton_pressed():
	get_tree().quit()
	
func button_mouse_entered(button):
	if button.can_process():
		button.grab_focus()

func button_focused(button):
	if !button.can_process():
		options.set_focus()

func _on_StartButton_mouse_entered():
	button_mouse_entered(start_button)

func _on_OptionsButton_mouse_entered():
	button_mouse_entered(options_button)

func _on_ExitButton_mouse_entered():
	button_mouse_entered(exit_button)

func _on_StartButton_focus_entered():
	button_focused(start_button)

func _on_OptionsButton_focus_entered():
	button_focused(options_button)

func _on_ExitButton_focus_entered():
	button_focused(exit_button)
