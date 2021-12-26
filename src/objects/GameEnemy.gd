extends GameCharacter
class_name GameEnemy

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer

enum State {
	IDLE,
	HIT,
	DEAD,
}

export(int) var life = 20

var _state = State.IDLE
var _direction = -1
var current_knockback = Vector2.ZERO
var knockback_direction = -1

func _ready() -> void:
	$Data/GameHurtbox.set_enemy(self)
	_velocity.x = speed.x

func set_direction(direction):
	_direction = direction

func get_direction():
	return _direction

func invert_direction():
	set_direction(get_direction() * -1)

func flip_sprite_based_on_direction():
	sprite.scale.x = _direction
	$Data.scale.x = _direction

func update_animation():
	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)

func destroy():
	_state = State.DEAD
	_velocity = Vector2.ZERO

func get_new_animation():
	if _state == State.HIT:
		return "Hit"

	return "Idle"

func _physics_process(_delta):
	if _state == State.DEAD:
		dead_state()
		return

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
	knockback_direction = direction
	life = max(life - damage, 0)
	_state = State.HIT

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Hit":
		if life > 0:
			_state = State.IDLE
		else:
			_state = State.DEAD
		return
		
	if anim_name == "Destroy":
		visible = false
		call_deferred("queue_free")
		return
