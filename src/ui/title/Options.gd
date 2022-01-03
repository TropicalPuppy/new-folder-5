extends Control

onready var music_check = $Music/CheckButton
onready var sfx_check = $SFX/CheckButton
onready var volume_slider = $VolumeSlider
onready var back_button = $BackButton


func _ready():
	volume_slider.value = Settings.master_volume
	music_check.pressed = Settings.music_enabled
	sfx_check.pressed = Settings.sfx_enabled

func _on_MusicCheckButton_toggled(button_pressed):
	Settings.music_enabled = button_pressed

func _on_SFXCheckButton_toggled(button_pressed):
	Settings.sfx_enabled = button_pressed

func _on_VolumeSlider_value_changed(value):
	Settings.master_volume = value

func _on_BackButton_pressed():
	close()

func _physics_process(_delta):
	if !visible:
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		close()

func open():
	get_tree().paused = true
	call_deferred("show")

func show():
	visible = true
	music_check.grab_focus()

func close():
	visible = false	
	get_tree().set_deferred("paused", false)
	
	Settings.save_settings()

func set_focus():
	music_check.grab_focus()
