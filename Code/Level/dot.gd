class_name Dot extends Collectable #Area2D

@export var _score: int = 10

func collect(pacman : Pacman) -> bool:
	if not super.collect(pacman):		#super suorittaa ensin kantaluokan (Collectable)
		return false
	
	GameManager.add_score(_score)

	return true
