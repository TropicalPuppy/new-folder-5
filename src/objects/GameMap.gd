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
