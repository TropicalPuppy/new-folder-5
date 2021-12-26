extends Control

var max_life = 100 setget set_max_life
var life = 100 setget set_life

func set_max_life(value):
	max_life = max(1, value)
	life = min(life, max_life)
	update_life()

func set_life(value):
	life = clamp(value, 0, max_life)
	update_life()
	
func update_life():
	$Life/Color.rect_size.x = clamp(life * 100.0 / max_life, 0, 100)

func _ready():
	self.max_life = Game.max_life
	self.life = Game.current_life
	
	# warning-ignore:return_value_discarded
	Game.connect("life_changed", self, "set_life")
	# warning-ignore:return_value_discarded
	Game.connect("max_life_changed", self, "set_max_life")
