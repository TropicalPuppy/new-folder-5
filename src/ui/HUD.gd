extends Control

var max_life = 100 setget set_max_life
var life = 100 setget set_life
var money = 0 setget set_money

var max_life_display = 100
var life_display = 100
var money_display = 0

var max_life_display_delta = 0.0
var life_display_delta = 0.0
var money_display_delta = 0.0

func calc_delta(display, value, max_time = 60):
	return max(0.2, abs(display - value) / max_time)

func set_max_life(value):
	max_life = max(1, value)
	life = min(life, max_life)
	max_life_display_delta = calc_delta(max_life_display, max_life)
	life_display_delta = calc_delta(life_display, life)
	
	update_life()

func set_life(value):
	life = clamp(value, 0, max_life)
	life_display_delta = calc_delta(life_display, life)
	update_life()

func set_money(value):
	money = value
	money_display_delta = calc_delta(money_display, money, 120)
	update_money()

func update_life():
	if max_life_display != max_life:
		max_life_display = max_life

	if life_display != life:
		life_display = move_toward(life_display, life, life_display_delta)
	
	$Life/Color.rect_size.x = clamp(life_display * 100.0 / max_life_display, 0, 100)
	$Life/Label.text = String(int(life_display))

func update_money():
	if money_display != money:
		money_display = move_toward(money_display, money, money_display_delta)
	
	$Money/Label.text = String(int(money_display))

func _ready():
	update_all_data()
	
	# warning-ignore:return_value_discarded
	Game.connect("life_changed", self, "set_life")
	# warning-ignore:return_value_discarded
	Game.connect("max_life_changed", self, "set_max_life")
	# warning-ignore:return_value_discarded
	Game.connect("money_changed", self, "set_money")

	# warning-ignore:return_value_discarded
	Game.connect("level_up", self, "level_up")
	
	# warning-ignore:return_value_discarded
	Game.connect("data_change", self, "update_all_data")
	

func _physics_process(_delta):
	if max_life_display != max_life or life_display != life:
		update_life()
	if money_display != money:
		update_money()

func level_up():
	$LevelUp/AnimationPlayer.play("Animate")

func update_all_data():
	max_life_display = Game.max_life
	life_display = Game.current_life
	money_display = Game.money
	self.max_life = Game.max_life
	self.life = Game.current_life
	self.money = Game.money
