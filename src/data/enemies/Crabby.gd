extends GameMovingEnemy

onready var player_detector = $Data/PlayerDetector

func idle_state():
	if player_detector.is_colliding():
		return

	handle_movement()
