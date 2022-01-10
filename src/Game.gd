extends Node

onready var screen = GameScreen.new()
onready var scenes = SceneManager.new()
onready var maps = MapManager.new()

signal life_changed
signal max_life_changed
signal stuck_sword
signal update_player_position
signal update_map
signal create_debris
signal play_sfx_at
signal play_sfx
signal money_changed
signal xp_changed
signal level_up
signal call_menu
signal damage
signal player_died
signal data_change
signal save_state

var player_scene = null setget set_player_scene
#var player = null setget set_player

var _initialized = false setget set_nothing
var map_name = null setget set_nothing
var player_x = null setget set_nothing
var player_y = null setget set_nothing
var current_scene_name setget set_nothing

var max_life = 100 setget set_max_life
var current_life = 100 setget set_life
var can_double_jump = false
var money = 0
var xp = 0
var next_level_xp = 0
var walk_xp = 0
var jump_xp = 0
var hit_xp = 0
var swing_xp = 0
var level = 1
var has_sword = false
var map_state_to_load = null setget set_nothing
var last_checkpoint_state = null

func set_max_life(value):
	max_life = max(1, value)
	emit_signal("max_life_changed", value)
	var new_life = clamp(current_life, 0, value)
	if (new_life != current_life):
		set_life(new_life)

func set_life(value):
	var old_life = current_life
	current_life = clamp(value, 0, max_life)
	emit_signal("life_changed", current_life)
	if current_life == 0 and old_life > 0:
		emit_signal("player_died")

func increase_money(increase):
	money = money + increase
	emit_signal("money_changed", money)

func _ready() -> void:
	pass

func _exit_tree():
	screen.queue_free()
	scenes.queue_free()
	maps.queue_free()

func initialize() -> void:
	pass

func change_scene(new_scene) -> void:
	_initialized = true
	current_scene_name = new_scene
	var scene_path = scenes.get_scene_path(new_scene)
	if (scene_path == null):
		scene_path = new_scene
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene(scene_path)
	get_tree().paused = false

func set_player_scene(scene_path) -> void:
	player_scene = scene_path

func set_nothing(_value) -> void:
	pass

func get_scene():
	return get_tree().current_scene
	
func set_player_position(x, y) -> void:
	player_x = x
	player_y = y
	if _initialized == false:
		return
		
	emit_signal("update_player_position")

func teleport_player(new_map_name, x, y) -> void:
	map_name = new_map_name
	player_x = x
	player_y = y

	if _initialized == false:
		return
		
	emit_signal("update_map")
	emit_signal("update_player_position")

func collect_item(item_id):
	match item_id:
		'Sword':
			has_sword = true
		'GoldenSkull':
			set_max_life(max_life + 20)
			set_life(max_life)
		'SilverCoin':
			increase_money(1)
		'GoldCoin':
			increase_money(5)
		'GreenDiamond':
			increase_money(25)
		'RedDiamond':
			increase_money(50)
		'BlueDiamond':
			increase_money(100)

func create_stuck_sword(position, direction, quick_destroy = false):
	emit_signal("stuck_sword", position, direction, quick_destroy)

func lose_sword():
	pass

func take_damage(damage):
	set_life(current_life - damage)
	Game.add_hit_xp(damage / 10.0)

func create_debris(debris, position, direction):
	emit_signal("create_debris", debris, position, direction)

func play_sfx_at(sfx, position, volume = 0.0):
	emit_signal("play_sfx_at", sfx, position, volume)

func play_sfx(sfx, volume = 0.0):
	emit_signal("play_sfx", sfx, volume)

func call_menu():
	emit_signal("call_menu")

func add_xp(amount):
	if level >= 20:
		return

	xp += amount
	emit_signal("xp_changed", xp)
	check_xp()

func add_side_xp(amount, current, max_allowed):
	update_required_xp()
	var max_side_xp = next_level_xp * max_allowed
	if current >= max_side_xp:
		return 0
	
	var new_amount = min(amount, max_side_xp - current)
	add_xp(new_amount)
	return new_amount
	

func add_walk_xp(amount):
	walk_xp += add_side_xp(amount, walk_xp, 0.2)

func add_jump_xp(amount):
	jump_xp += add_side_xp(amount, jump_xp, 0.1)

func add_hit_xp(amount):
	hit_xp += add_side_xp(amount, hit_xp, 0.4)

func add_swing_xp(amount):
	swing_xp += add_side_xp(amount, swing_xp, 0.2)

func check_xp():
	if level >= 20:
		return
	
	update_required_xp()
	if xp >= next_level_xp:
		level_up()
		return

func update_required_xp():
	next_level_xp = get_required_xp(level + 1)

func level_up():
	level += 1
	xp = 0
	jump_xp = 0
	walk_xp = 0
	hit_xp = 0
	swing_xp = 0
	
	set_max_life(max_life + 10)
	
	var life_restore = 10 + int(max_life / 100) * level * 5
	set_life(current_life + life_restore)
	update_required_xp()
	emit_signal("level_up")
	
func get_required_xp(for_level):
	return (for_level - 2) * 10 + 100
	
func show_damage(damage, position, is_player = false):
	emit_signal("damage", damage, position, is_player)

func reset():
	max_life = 100
	current_life = 100
	can_double_jump = false
	money = 0
	xp = 0
	next_level_xp = 0
	walk_xp = 0
	jump_xp = 0
	hit_xp = 0
	swing_xp = 0
	level = 1
	has_sword = false
	map_state_to_load = null
	
	update_required_xp()
	emit_signal("data_change")
	go_to_start()

func save_state(position = null):
	var state = SaveState.new()

	state.max_life = max_life
	state.current_life = current_life
	state.can_double_jump = can_double_jump
	state.money = money
	state.xp = xp
	state.walk_xp = walk_xp
	state.jump_xp = jump_xp
	state.hit_xp = hit_xp
	state.swing_xp = swing_xp
	state.level = level
	state.has_sword = has_sword
	
	if position != null:
		state.position = position
	else:
		state.position = get_start_position()
	
	emit_signal("save_state", state)
	
	return state

func restore_state(state):
	max_life = state.max_life
	current_life = state.max_life
#	current_life = state.current_life
	money = state.money
	can_double_jump = state.can_double_jump
	xp = state.xp
	walk_xp = state.walk_xp
	jump_xp = state.jump_xp
	hit_xp = state.hit_xp
	swing_xp = state.swing_xp
	level = state.level
	has_sword = state.has_sword

	update_required_xp()
	map_state_to_load = state.map
	emit_signal("data_change")

	if state.position != null:
		teleport_player(state.position.map, state.position.x, state.position.y)
	else:
		go_to_start()

func save_checkpoint(position = null):
	last_checkpoint_state = save_state(position)

func restore_checkpoint():
	if last_checkpoint_state != null:
		restore_state(last_checkpoint_state)
		return

	reset()

func report_map_loaded(_map_name):
	map_state_to_load = null

func get_start_position():
	return {
		"map": "Island1",
		"x": 23,
		"y": 700
	}

func go_to_start():
	var pos = get_start_position()
	
	teleport_player(pos.map, pos.x, pos.y)
