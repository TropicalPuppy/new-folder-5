extends Node2D
class_name SceneMap

onready var y_sort = $YSort
onready var map_holder = $MapHolder
onready var camera = $Camera2D

const StuckSwordScene = preload("res://src/data/platforms/StuckSword.tscn")
const RunEffectScene = preload("res://src/data/sprites/RunEffect.tscn")
const JumpEffectScene = preload("res://src/data/sprites/JumpEffect.tscn")
const FallEffectScene = preload("res://src/data/sprites/FallEffect.tscn")

var initialized = false
var is_ready = false
var auto_initialize = false

func _ready() -> void:
	is_ready = true
	if auto_initialize:
		initialize()
	
	# warning-ignore:return_value_discarded
	Game.connect("recall_sword", self, "destroy_all_swords")
	# warning-ignore:return_value_discarded
	Game.connect("stuck_sword", self, "create_stuck_sword")
	# warning-ignore:return_value_discarded
	Game.connect("update_map", self, "update_map")
	
func load_initial_player() -> void:
	if y_sort.get_child_count() == 0:
		load_player()

	var game_player = y_sort.get_child(0)
	if Game.player_x != null and Game.player_y != null:
		game_player.position.x = Game.player_x
		game_player.position.y = Game.player_y
	
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
	load_map(Game.map_name)

func load_map(map_name) -> void:
	var map_path = Game.maps.get_scene_path(map_name)
	var map_class = load(map_path)
	var map_instance = map_class.instance()

	while map_holder.get_child_count() > 0:
		var old_map = map_holder.get_child(0)
		map_holder.remove_child(old_map)
		old_map.clear_map()
	
	map_holder.add_child(map_instance)
	
	camera.limit_right = map_instance.width
	camera.limit_bottom = map_instance.height	

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
