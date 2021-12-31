class_name TotemHead
extends GameEnemyGun

onready var player_detection_above = $Data/PlayerDetectionAbove

func _on_TotemHeadTemplate_create_bullet(bullet):
	if player_detection_above.can_see_player():
		bullet.damage_cooldown = 0.2
