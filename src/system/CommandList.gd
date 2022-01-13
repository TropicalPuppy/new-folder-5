extends Node

func copy_list():
	var children = self.get_children()
	var list = []

	for child in children:
		if child is Command:
			list.append(child.clone())
	
	return list

func execute(context):
	Game.run_code(copy_list(), context)
