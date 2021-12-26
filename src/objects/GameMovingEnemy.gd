class_name GameMovingEnemy
extends GameEnemy

onready var platform_detector = $PlatformDetector
onready var floor_detector_left = $FloorDetectorLeft
onready var floor_detector_right = $FloorDetectorRight

const FLOOR_DETECT_DISTANCE = 20.0

func _ready():
	animation_player.play("Idle")

func get_new_animation():
	if _state == State.HIT:
		return "Hit"

	if !is_on_floor():
		if _velocity.y > 0:
			return "Fall"

		return "Jump"
		
	if _velocity.x != 0:
		return "Walk"

	return "Idle"

func flip_direction_to_avoid_falling():
	if not floor_detector_left.is_colliding():
		set_direction(1)
	elif not floor_detector_right.is_colliding():
		set_direction(-1)
	
func apply_velocity(direction: Vector2, is_jump_interrupted: bool) -> void:
	_velocity = .calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform = platform_detector.is_colliding()
	_velocity = move_and_slide_with_snap(_velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false)

func handle_movement():
	flip_directions_on_wall()
	flip_direction_to_avoid_falling()

	apply_velocity(Vector2(get_direction(), _velocity.y), true)

func dead_state():
	.dead_state()
	apply_velocity(Vector2(0, _velocity.y), true)

func hit_state():
	if current_knockback != Vector2.ZERO:
		apply_velocity(current_knockback, true)

func idle_state():
	handle_movement()

func flip_directions_on_wall():
	if is_on_wall():
		invert_direction()


