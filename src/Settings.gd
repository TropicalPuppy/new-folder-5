extends Node

const settings_file = "user://settings.save"

var master_volume = 100 setget set_master_volume
var music_enabled = true setget set_music_enabled
var sfx_enabled = true setget set_sfx_enabled

func set_master_volume(value):
	master_volume = value
	AudioServer.set_bus_volume_db(0, linear2db(value / 100.0))

func set_music_enabled(value):
	music_enabled = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), !value)

func set_sfx_enabled(value):
	sfx_enabled = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), !value)

func save_settings():
	var file = File.new()
	file.open(settings_file, File.WRITE)
	file.store_var(master_volume)
	file.store_var(music_enabled)
	file.store_var(sfx_enabled)
	file.close()

func load_settings():
	var file = File.new()
	if file.file_exists(settings_file):
		file.open(settings_file, File.READ)
		self.master_volume = file.get_var()
		self.music_enabled = file.get_var()
		self.sfx_enabled = file.get_var()
		file.close()

func _ready():
	load_settings()
