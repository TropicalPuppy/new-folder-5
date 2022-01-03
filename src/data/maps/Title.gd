extends GameMap

func reset_ship():
	$SailingShip.position = Vector2(-16, 295)

func _ready():
	$SailingShip/AnimationPlayer2.advance(15)
