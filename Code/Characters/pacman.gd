class_name Pacman extends CharacterBody2D

const SPEED : float = 150.0
const TILE_SIZE : int = 16

var direction : Vector2 = Vector2.RIGHT
var next_direction : Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	_read_input()
	_move()
	# TODO: animaatiot ja hahmon kääntyminen
	#_update_animations()
	
func _read_input() -> void:
	if Input.is_action_pressed("Right"):
		next_direction = Vector2.RIGHT
	elif Input.is_action_pressed("Left"):
		next_direction = Vector2.LEFT
	elif Input.is_action_pressed("Up"):
		next_direction = Vector2.UP
	elif Input.is_action_pressed("Down"):
		next_direction = Vector2.DOWN

func _move() -> void:
	if _is_on_grid():
		if not _is_direction_blocked(next_direction):
			direction = next_direction
		if _is_direction_blocked(direction):
			velocity = Vector2.ZERO
			return
	velocity = direction * SPEED
	move_and_slide()
	
#Tarkistetaan, onko hahmo ruudukon kohdalla
func _is_on_grid() -> bool:
	return int(position.x) % TILE_SIZE == 0 and int(position.y) % TILE_SIZE == 0
	
func _is_direction_blocked(dir : Vector2) -> bool:
	var collision = move_and_collide(dir * TILE_SIZE, true)
	return collision != null
