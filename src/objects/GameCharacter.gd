extends KinematicBody2D
class_name GameCharacter

# Both the Player and Enemy inherit this scene as they have shared behaviours
# such as speed and are affected by gravity.

export var speed = Vector2(150.0, 350.0)
export(bool) var enable_gravity = true
onready var gravity = ProjectSettings.get("physics/2d/default_gravity")

const FLOOR_NORMAL = Vector2.UP

var _velocity = Vector2.ZERO

# _physics_process is called after the inherited _physics_process function.
# This allows the Player and Enemy scenes to be affected by gravity.
func _physics_process(delta):
	if enable_gravity:
		increase_fall_speed(delta)

func increase_fall_speed(delta):
	if !is_on_floor():
		_velocity.y += gravity * delta

func calculate_move_velocity(linear_velocity, direction, move_speed, is_jump_interrupted):
	var velocity = linear_velocity
	velocity.x = move_speed.x * direction.x
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted and velocity.y < 0:
		# Decrease the Y velocity by multiplying it, but don't set it to 0
		# as to not be too abrupt.
		velocity.y *= 0.6
	return velocity

