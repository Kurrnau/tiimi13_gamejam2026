class_name PowerUp extends Collectable #Area2D

signal powerup_eaten					#TEST

@export var _score: int = 50

func collect(pacman : Pacman) -> bool:
	if not super.collect(pacman):
		return false
	
	GameManager.add_score(_score)
	_on_powerup_eaten()					#TEST

	return true

func _on_powerup_eaten():				#TEST
	emit_signal("powerup_eaten")
