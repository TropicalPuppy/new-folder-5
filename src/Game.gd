extends Node

onready var text = GameText.new()
onready var screen = GameScreen.new()
onready var scenes = SceneManager.new()
onready var maps = MapManager.new()

signal life_changed
signal max_life_changed
signal stuck_sword
signal recall_sword
signal update_player_position
signal update_map
signal create_debris
signal play_sfx_at

const lose_sword_when_throwing = false

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
var gold = 0
var jump_exp = 0
var run_exp = 0
var has_sword = false
var lost_sword = false

func set_max_life(value):
	max_life = max(1, value)
	emit_signal("max_life_changed", value)
	var new_life = clamp(current_life, 0, value)
	if (new_life != current_life):
		set_life(new_life)

func set_life(value):
	current_life = clamp(value, 0, max_life)
	emit_signal("life_changed", value)

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

func create_stuck_sword(position, direction, quick_destroy = false):
	emit_signal("stuck_sword", position, direction, quick_destroy)
	lose_sword()

func lose_sword():
	if lose_sword_when_throwing:
		lost_sword = true

func recall_sword():
	lost_sword = false
	emit_signal("recall_sword")

func take_damage(damage):
	set_life(current_life - damage)

func create_debris(debris, position, direction):
	emit_signal("create_debris", debris, position, direction)

func play_sfx_at(sfx, position):
	emit_signal("play_sfx_at", sfx, position)
