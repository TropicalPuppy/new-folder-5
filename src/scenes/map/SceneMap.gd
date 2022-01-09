extends Node2D
class_name SceneMap

onready var y_sort = $YSort
onready var map_holder = $MapHolder
onready var camera = $Camera2D
onready var audio2d = $AudioStreamPlayer2D
onready var audio = $AudioStreamPlayer
onready var audio2db = $AlternativeAudioStreamPlayer2D
onready var audiob = $AlternativeAudioStreamPlayer
onready var map_ui = $MapUI

const StuckSwordScene = preload("res://src/data/platforms/StuckSword.tscn")
const RunEffectScene = preload("res://src/data/sprites/RunEffect.tscn")
const JumpEffectScene = preload("res://src/data/sprites/JumpEffect.tscn")
const FallEffectScene = preload("res://src/data/sprites/FallEffect.tscn")
const DamageIndicator = preload("res://src/data/sprites/DamageIndicator.tscn")
const PlayerDamageIndicator = preload("res://src/data/sprites/PlayerDamageIndicator.tscn")

var initialized = false
var is_ready = false
var auto_initialize = false

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		call_menu()

func _ready() -> void:
	is_ready = true
	if auto_initialize:
		initialize()
	
	# warning-ignore:return_value_discarded
	Game.connect("stuck_sword", self, "create_stuck_sword")
	# warning-ignore:return_value_discarded
	Game.connect("update_map", self, "update_map")
	# warning-ignore:return_value_discarded
	Game.connect("create_debris", self, "create_debris")
	# warning-ignore:return_value_discarded
	Game.connect("play_sfx_at", self, "play_sfx_at")
	# warning-ignore:return_value_discarded
	Game.connect("play_sfx", self, "play_sfx")
	# warning-ignore:return_value_discarded
	Game.connect("call_menu", self, "call_menu")
	# warning-ignore:return_value_discarded
	Game.connect("damage", self, "show_damage")
	
func load_initial_player() -> void:
	if y_sort.get_child_count() == 0:
		load_player()

	var game_player = y_sort.get_child(0)
	if Game.player_x != null and Game.player_y != null:
		game_player.position.x = Game.player_x
		game_player.position.y = Game.player_y
	game_player.set_camera_path("../../../Camera2D")

	# warning-ignore:return_value_discarded
	game_player.connect("run", self, "create_run_effect")
	# warning-ignore:return_value_discarded
	game_player.connect("jump", self, "create_jump_effect")
	# warning-ignore:return_value_discarded
	game_player.connect("fall", self, "create_fall_effect")

func load_player() -> void:
	var player_scene = Game.player_scene
	if (player_scene == null):
		player_scene = "res://src/objects/GamePlayer.tscn"
	
	var loaded_scene = load(player_scene)
	var game_player = loaded_scene.instance()
	game_player.set_camera_path("../../../Camera2D")
	y_sort.add_child(game_player)
	
func update_map() -> void:
	call_deferred("load_map", Game.map_name)
	
func unload_map():
	while map_holder.get_child_count() > 0:
		var old_map = map_holder.get_child(0)
		map_holder.remove_child(old_map)
		old_map.call_deferred("queue_free")
	

func load_map(map_name) -> void:
	unload_map()

	var map_path = Game.maps.get_scene_path(map_name)
	var map_class = load(map_path)
	var map_instance = map_class.instance()
	
	map_holder.add_child(map_instance)
	
	camera.limit_left = map_instance.get_left()
	camera.limit_top = map_instance.get_top()
	camera.limit_right = map_instance.get_right()
	camera.limit_bottom = map_instance.get_bottom()

	# warning-ignore:return_value_discarded
	Game.connect("save_state", map_instance, "save_state")
	
	if Game.map_state_to_load != null:
		map_instance.apply_map_state(Game.map_state_to_load)

	Game.report_map_loaded(map_name)

func initialize():
	if initialized:
		return
	
	load_initial_player()
	if Game.map_name:
		load_map(Game.map_name)
	initialized = true

func _on_SceneMap_tree_entered() -> void:
	if is_ready:
		initialize()
	else:
		auto_initialize = true

func create_stuck_sword(position, direction, quick_destroy):
	var sword = StuckSwordScene.instance()
	sword.global_position = position
	sword.set_as_toplevel(true)
	sword.set_direction(direction)
	sword.set_quick_destroy(quick_destroy)
	add_child(sword)

func destroy_all_swords():
	var children = get_children()
	for node in children:
		if node is StuckSword:
			node.call_deferred("queue_free")
		elif node is ThrownSword:
			node.call_deferred("queue_free")

func add_player_effect(effect, position, direction):
	effect.scale.x = direction
	effect.global_position = Vector2(position.x, position.y + 2)
	effect.connect("animation_finished", effect, "queue_free", [], CONNECT_DEFERRED)
	effect.set_as_toplevel(true)
	effect.z_index = -1
	add_child(effect)
	
	effect.play()

func create_run_effect(position, direction):
	add_player_effect(RunEffectScene.instance(), position, direction)
	
func create_jump_effect(position, direction):
	add_player_effect(JumpEffectScene.instance(), position, direction)

func create_fall_effect(position, direction):
	add_player_effect(FallEffectScene.instance(), position, direction)

func create_debris(debris, position, direction):
	debris.global_position = position
	debris.apply_impulse(Vector2.ZERO, direction)
	call_deferred("add_child", debris)

func play_sfx_at(sfx, position, volume = 0):
	var player = audio2db if audio2d.playing else audio2d
	
	player.global_position = position
	player.volume_db = volume
	player.stream = sfx
	player.play()

func play_sfx(sfx, volume = 0):
	var player = audiob if audio.playing else audio
	
	player.volume_db = volume
	player.stream = sfx
	player.play()

func call_menu():
	map_ui.call_menu()

func show_damage(damage, position, is_player = false):
	var type = PlayerDamageIndicator if is_player else DamageIndicator
	
	var indicator = type.instance()
	indicator.rect_position = position
	indicator.set_as_toplevel(true)
	indicator.set_value(int(damage))
	add_child(indicator)
