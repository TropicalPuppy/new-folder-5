extends Control

func _ready():
	$VolumeSlider.value = Game.master_volume
	$Music/CheckButton.pressed = Game.music_enabled
	$SFX/CheckButton.pressed = Game.sfx_enabled

func _physics_process(_delta):
	if !visible:
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		close()

func _on_VolumeSlider_value_changed(value):
	Game.master_volume = value

func _on_MusicCheckButton_toggled(button_pressed):
	Game.music_enabled = button_pressed

func _on_SFXCheckButton_toggled(button_pressed):
	Game.sfx_enabled = button_pressed

func open():
	get_tree().paused = true
	set_deferred("visible", true)

func close():
	visible = false	
	get_tree().set_deferred("paused", false)

func _on_CloseButton_pressed():
	pass


func _on_BackButton_pressed():
	close()
