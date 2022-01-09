extends StaticBody2D
class_name GameMap

func get_top():
	return $TopLeftLimit.position.y

func get_left():
	return $TopLeftLimit.position.x

func get_bottom():
	return $BottomRightLimit.position.y

func get_right():
	return $BottomRightLimit.position.x

func map_object_exists(path):
	var node = get_node_or_null(path)
	if node == null:
		return false
	
	if node.was_collected:
		return false
	
	if node.is_destroying():
		return false
	
	return true

func get_map_state():
	var path_list = get_object_path_list()
	var objects = {}
	for path in path_list:
		objects[path] = map_object_exists(path)
	
	return {
		"objects": objects
	}

func save_state(state):
	state.map = get_map_state()

func load_state(state):
	if state.map != null:
		apply_map_state(state.map)

func apply_map_state(map_state):
	if map_state.objects == null:
		return

	var path_list = get_object_path_list()
	for path in path_list:
		apply_object_state(path, map_state.objects[path])

func apply_object_state(path, state):
	if state == true:
		return

	var node = get_node_or_null(path)
	if node == null:
		return
	
	node.queue_free()

func get_object_path_list():
	return []
