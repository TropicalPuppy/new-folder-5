class_name Code
extends Node2D

onready var wait_timer = $WaitTimer

var command_index = -1
var wait_mode = Constants.WaitMode.NONE
var defer_count = 0
var list = []
var context = null

func initialize():
	clear_data()

func clear_data():
	free_list()
	reset_state()

func reset_state():
	command_index = -1
	wait_mode = Constants.WaitMode.NONE
	defer_count = 0
	

func free_list():
	if !list:
		return
	
	for cmd in list:
		if cmd != null and is_instance_valid(cmd):
			cmd.queue_free()

func _exit_tree():
	clear_data()

func setup(commands, code_context):
	clear_data()
	context = code_context
	
	if commands != null and commands is Array:
		list = commands
	else:
		list = []
	
	for cmd in list:
		cmd.clear_work_data()

func is_running():
	return list != null and list.size() > 0 and command_index >= 0 and command_index < list.size()

func process_list(delta):
	while is_running():
		if !wait_timer.is_stopped():
			break
		
		if is_waiting():
			break
		
		wait_mode = Constants.WaitMode.NONE
			
		if execute_next_command(delta):
			break
	
	after_processing()

func is_waiting():
	match wait_mode:
		Constants.WaitMode.SCREEN:
			return Game.is_fading
		Constants.WaitMode.DEFER:
			if defer_count > 0:
				defer_count -= 1
				return true

			return false
	
	return false

func _execute_command(command, delta):
	if !command.enabled:
		skip()
		return true

	print("Execute command")
	print(command)
	var result = command.execute_command(self, delta)
	
	if result != false:
		skip()

	return result

func execute_next_command(delta):
	var command = current_command()
	if !command or !is_instance_valid(command):
		stop()
		return true
	
	if command is Command:
		return _execute_command(command, delta)

	print("Unexpected node on command list")
	print(command)

	skip()
	return true

func wait(duration: float):
	wait_timer.start(duration)

func defer(amount = 1):
	defer_count += amount

func current_command():
	if command_index < 0 or command_index >= list.size():
		return null
	
	return list[command_index]

func skip():
	var command = current_command()
	if command:
		command.queue_free()

	command_index += 1

func stop():
	command_index = -1

func start():
	print("Start")
	print(list.size())
	reset_state()
	command_index = 0

func _physics_process(delta):
	process_list(delta)

func after_processing():
	pass

