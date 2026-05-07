class_name BlueGhost extends Ghost

@export var red_ghost: Ghost

func _get_chase_target() -> Vector2:
	if red_ghost == null:
		return _pacman.position
		
	var two_ahead = _pacman.position + _pacman.direction * TILE_SIZE * 2
	var to_target = two_ahead - red_ghost.position
	return two_ahead + to_target
