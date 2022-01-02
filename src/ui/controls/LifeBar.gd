extends Control

export(int) var max_life = 100 setget set_max_life
export(int) var life = 100 setget set_life

var max_life_display = 100
var life_display = 100

var max_life_display_delta = 0.0
var life_display_delta = 0.0

func calc_delta(display, value):
	return max(0.2, abs(display - value) / 10)

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

func update_life():
	if max_life_display != max_life:
		max_life_display = max_life

	if life_display != life:
		life_display = move_toward(life_display, life, life_display_delta)
	
	$Color.rect_size.x = clamp(life_display * 25.0 / max_life_display, 0, 25)

func _ready():
	max_life_display = max_life
	life_display = life

func _physics_process(_delta):
	if max_life_display != max_life or life_display != life:
		update_life()
