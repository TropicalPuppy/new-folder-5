extends GameCharacter
class_name GameEnemy

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var collision_shape = $CollisionShape2D

enum State {
	IDLE,
	HIT,
	DEAD,
}

enum Direction {
	LEFT,
	RIGHT
}

export(int) var life = 20
export(bool) var manage_enemy_layer = true
export(Direction) var initial_direction = Direction.LEFT
export(float) var x_offset_when_facing_left = 0
export(float) var x_offset_when_facing_right = 0

export(String, FILE, "*.tscn,*.scn") var loot_1_scene = ''
export(float) var loot_1_chance = 10.0
export(String, FILE, "*.tscn,*.scn") var loot_2_scene = ''
export(float) var loot_2_chance = 50.0
export(String, FILE, "*.tscn,*.scn") var loot_3_scene = ''
export(float) var loot_3_chance = 100.0

var _state = State.IDLE
var _direction = -1
var current_knockback = Vector2.ZERO
var knockback_direction = -1
var original_collision_x = 0

var LootType = null

func _ready() -> void:
	$Data/GameHurtbox.set_enemy(self)
	_velocity.x = speed.x
	if initial_direction == Direction.RIGHT:
		_direction = 1
	
	original_collision_x = collision_shape.position.x

	var rng = randi() % 100
	if loot_1_scene != '' and rng > (100 - loot_1_chance):
		LootType = load(loot_1_scene)
	elif loot_2_scene != '' and rng > (100 - loot_2_chance):
		LootType = load(loot_2_scene)
	elif loot_3_scene != '' and rng > (100 - loot_3_chance):
		LootType = load(loot_3_scene)

func set_direction(direction):
	_direction = direction

func get_direction():
	return _direction

func invert_direction():
	set_direction(get_direction() * -1)

func flip_sprite_based_on_direction():
	sprite.scale.x = _direction
	$Data.scale.x = _direction
	if x_offset_when_facing_left != x_offset_when_facing_right:
		var offset = x_offset_when_facing_left if _direction < 0 else x_offset_when_facing_right
		collision_shape.position.x = original_collision_x + offset

func update_animation():
	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)

func destroy():
	_state = State.DEAD
	_velocity = Vector2.ZERO
	
	if LootType != null:
		Game.create_debris(LootType.instance(), global_position, Vector2.UP * 100)

func get_new_animation():
	if _state == State.HIT:
		return "Hit"

	return "Idle"

func _physics_process(_delta):
	if _state == State.DEAD:
		dead_state()
		return

	if manage_enemy_layer:
		set_collision_layer_bit(1, _state == State.IDLE)

	match _state:
		State.HIT:
			hit_state()
		State.IDLE:
			idle_state()

	flip_sprite_based_on_direction()
	update_animation()

func dead_state():
	$Data/GameHitbox.disable()
	$Data/GameHurtbox.disable()
	animation_player.play("Destroy")

func hit_state():
	pass
	
func idle_state():
	pass

func _on_GameHurtbox_area_entered(area):
	get_hit(area.damage, -1 if area.position.x < position.x else 1)

func knockback(x, y):
	current_knockback.x = x * knockback_direction
	current_knockback.y = y

func is_invincible():
	return $Data/GameHurtbox/CollisionShape2D.disabled

func get_hit(damage, direction):
	var base_damage = (damage + Game.level) / 2.0

	var multiplier = (9 + Game.level) / 10.0
	var max_extra_damage = int(damage * multiplier)
	var extra_damage = randi() % max_extra_damage
	var real_damage = base_damage + extra_damage
	
#	print(self.name + " took " + String(real_damage) + " damage")
	
	knockback_direction = direction
	life = max(life - real_damage, 0)
	_state = State.HIT
	Game.add_xp(damage / 5.0)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Hit":
		if life > 0:
			_state = State.IDLE
		else:
			destroy()
		return
		
	if anim_name == "Destroy":
		visible = false
		call_deferred("queue_free")
		return
