class_name PowerUp extends Collectable #Area2D

@export var _score: int = 50

func collect(pacman : Pacman) -> bool:
	if not super.collect(pacman):
		return false
	
	GameManager.add_score(_score)
	#TODO: muu toiminnallisuus (värin vaihto? viholliset karkaa? tms?)

	return true
