class_name CustomCommand
extends Command

export(Array, String) var arguments = []

signal execute

func execute_command(code, _delta):
	var data = {
		"result": true
	}
	
	emit_signal("execute", data, code)
	
	return data.result
