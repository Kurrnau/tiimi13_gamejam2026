class_name OrangeGhost extends Ghost

const PROXIMITY_THRESHOLD: int = 8

func _get_chase_target() -> Vector2:
	var distance_in_tiles = position.distance_to(_pacman.position) / TILE_SIZE
	if distance_in_tiles > PROXIMITY_THRESHOLD:
		return _pacman.position
	else:
		return scatter_target
