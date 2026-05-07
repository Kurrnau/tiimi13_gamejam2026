class_name PinkGhost extends Ghost

const AMBUSH_DISTANCE: int = 4

func _get_chase_target() -> Vector2:
	return _pacman.position + _pacman.velocity.normalized() * TILE_SIZE * AMBUSH_DISTANCE
