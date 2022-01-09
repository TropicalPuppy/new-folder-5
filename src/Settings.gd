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
	file.store_var(make_settings())
	file.close()
	
func make_settings():
	return {
		"version": 1,
		"master_volume": self.master_volume,
		"music_enabled": self.music_enabled,
		"sfx_enabled": self.sfx_enabled
	}

func apply_settings(data):
	self.master_volume = data.master_volume
	self.music_enabled = data.music_enabled
	self.sfx_enabled = data.sfx_enabled

func load_settings():
	var file = File.new()
	if file.file_exists(settings_file):
		file.open(settings_file, File.READ)
		
		var data = file.get_var()
		print(data)
		if data is Dictionary:
			apply_settings(data)
		elif data is int:
			# Old format
			self.master_volume = data
			self.music_enabled = file.get_var()
			self.sfx_enabled = file.get_var()
		
		file.close()

func _ready():
	load_settings()
