extends Command

export(String) var map_name = ''
export(float) var x = 0
export(float) var y = 0

export(int) var defer_count = 2

var has_changed_position = false

func execute_command(code, _delta):
#	if has_changed_position:
#	Game.teleport_player(map_name, x, y)
	Game.fade_and_teleport(map_name, x, y, 1.0)
	code.defer(defer_count)
	return true
	
#	has_changed_position = true
#	Game.set_player_position(-100, -100)
#	code.defer(defer_count)
#	return false

func clear_work_data():
	has_changed_position = false
