extends Node

onready var text = GameText.new()
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

func set_max_life(value):
	max_life = max(1, value)
	emit_signal("max_life_changed", value)
	var new_life = clamp(current_life, 0, value)
	if (new_life != current_life):
		set_life(new_life)

func set_life(value):
	current_life = clamp(value, 0, max_life)
	emit_signal("life_changed", value)

func increase_money(increase):
	money = money + increase
	emit_signal("money_changed", money)

func _ready() -> void:
	pass

func initialize() -> void:
	pass

func push_scene(new_scene) -> void:
	_initialized = true
	current_scene_name = new_scene
	var scene_path = scenes.get_scene_path(new_scene)
	if (scene_path == null):
		scene_path = new_scene
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene(scene_path)

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
	update_required_xp()
	emit_signal("level_up")
	
func get_required_xp(for_level):
	return (for_level - 2) * 10 + 100
	
func show_damage(damage, position, is_player = false):
	emit_signal("damage", damage, position, is_player)
