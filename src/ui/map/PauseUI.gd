extends Control

onready var settings = $Settings
onready var volume_slider = $Settings/VolumeSlider
onready var music_check = $Settings/Music/CheckButton
onready var sfx_check = $Settings/SFX/CheckButton
onready var exit_button = $ExitButton
onready var exit_label = $ExitButton/Label
onready var level_bar = $LevelBar
onready var level_number = $LevelBar/LevelNumber
onready var level_color = $LevelBar/Color
onready var exiting = $Exiting
onready var back_button = $Settings/BackButton
onready var confirm_button = $Exiting/ConfirmButton
onready var cancel_button = $Exiting/CancelButton

func _ready():
	settings.visible = true
	exiting.visible = false
	volume_slider.value = Settings.master_volume
	music_check.pressed = Settings.music_enabled
	sfx_check.pressed = Settings.sfx_enabled
	update_level()

func _physics_process(_delta):
	if !visible:
		return
	
	if settings.visible:
		process_settings()
		return
	
	process_exit()

func process_settings():
	exit_label.rect_size.y = 16 if exit_button.pressed else 14

	if Input.is_action_just_pressed("ui_cancel"):
		close()
		return
	
	if !music_check.has_focus() and !sfx_check.has_focus() and !volume_slider.has_focus() and !exit_button.has_focus() and !back_button.has_focus():
		music_check.grab_focus()

func process_exit():
	if Input.is_action_just_pressed("ui_cancel"):
		abort_exiting()
		return
	
	if !confirm_button.has_focus() and !cancel_button.has_focus():
		cancel_button.grab_focus()

func _on_VolumeSlider_value_changed(value):
	Settings.master_volume = value

func _on_MusicCheckButton_toggled(button_pressed):
	Settings.music_enabled = button_pressed

func _on_SFXCheckButton_toggled(button_pressed):
	Settings.sfx_enabled = button_pressed

func open():
	get_tree().paused = true
	call_deferred("show")
	update_level()

func show():
	visible = true
	music_check.grab_focus()

func close():
	visible = false	
	get_tree().set_deferred("paused", false)
	Settings.save_settings()

func _on_BackButton_pressed():
	close()

func update_level():
	Game.update_required_xp()
	level_number.text = String(Game.level)
	level_color.rect_size.x = clamp(Game.xp * 50.0 / Game.next_level_xp, 0, 50)

func _on_ExitButton_pressed():
	settings.visible = false
	exit_button.visible = false
	level_bar.visible = false
	exiting.visible = true

func _on_CancelButton_pressed():
	abort_exiting()

func abort_exiting():
	settings.visible = true
	exit_button.visible = true
	level_bar.visible = true
	exiting.visible = false
	exit_button.grab_focus()

func confirm_exit():
	Game.change_scene("Title")

func _on_ConfirmButton_pressed():
	confirm_exit()
