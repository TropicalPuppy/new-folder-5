class_name Command
extends Node

export(bool) var enabled = true

func execute_command(_code, _delta):
	return true

func clear_work_data():
	pass

func clone():
	var packed_scene = PackedScene.new()
	packed_scene.pack(self)
	return packed_scene.instance()
