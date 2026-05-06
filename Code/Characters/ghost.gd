class_name Ghost extends CharacterBody2D

enum State { WAITING, CHASE, SCATTER, FRIGHTENED, LEAVING_HOME, EATEN }

@export var scatter_target: Vector2
@export var speed: float = 90.0
@export var home_exit: Vector2 = Vector2(320, 168)
@export var leaving_home_timer: float = 0.0
@export var scatter_duration: float = 7.0
@export var chase_duration: float = 20.0

@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#How the ghosts find pacman's position:
@onready var _pacman: Pacman = get_tree().get_first_node_in_group("pacman")


const TILE_SIZE: int = 16

var state: State = State.CHASE
var direction: Vector2 = Vector2.LEFT

var _scatter_timer: float = 7.0
var _chase_timer: float = 20.0

func _ready() -> void:
	position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))
	state = State.WAITING
	await get_tree().create_timer(leaving_home_timer).timeout
	state = State.LEAVING_HOME

func _physics_process(delta: float) -> void:
	_update_state(delta)
	_move()

#region Ghost movement	
# Movement on the 16x16 grid (same as pacman).
func _move() -> void:
	if state == State.WAITING:
		return
	if _is_on_grid(): 
		position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))
		if state == State.LEAVING_HOME and position.distance_to(home_exit) < TILE_SIZE:
			state = State.CHASE
		direction = _get_best_direction(_get_target())
	velocity = direction * speed
	move_and_slide()
	
func _is_on_grid() -> bool:
	var x_remainder = fmod(position.x, TILE_SIZE)
	var y_remainder = fmod(position.y, TILE_SIZE)
	return (x_remainder < 1.5 or x_remainder > TILE_SIZE - 1.5) and \
	   (y_remainder < 1.5 or y_remainder > TILE_SIZE - 1.5)

func _is_direction_blocked(dir: Vector2) -> bool:
	var collision = move_and_collide(dir * TILE_SIZE, true)
	# true = direction is blocked
	# false = direction is not blocked
	return collision != null

#How the ghost decides, where to move
func _get_best_direction(target: Vector2) -> Vector2:
	var directions = [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT]
	var best_direction = direction
	var best_distance = INF
	
	for dir in directions:
		if _is_direction_blocked(dir):
			continue
		# Ghosts can't change direction
		if dir == -direction and not _is_only_reverse_available():
			continue
		# Prevent ghost from re-entering home unless EATEN:
		if state != State.EATEN and position.y >= home_exit.y and dir == Vector2.DOWN:
			continue
		#Calculates direct distance from new position to target..
		var new_position = position + dir * TILE_SIZE
		var distance = new_position.distance_to(target)
		#.. and changes direction if that distance is shorter.
		if distance < best_distance:
			best_distance = distance
			best_direction = dir
	return best_direction

# If all other directions are blocked, the ghost will turn back (fx. end of spiral).
func _is_only_reverse_available() -> bool:
	for dir in [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT]:
		if dir == -direction:
			continue
		if  not _is_direction_blocked(dir):
			return false
	return true
#endregion


func _get_target() -> Vector2:
	match state:
		State.LEAVING_HOME:
			return home_exit
		State.CHASE:
			return _get_chase_target()
		State.SCATTER:
			return scatter_target
		State.FRIGHTENED:
			return _get_frightened_target()
	return scatter_target

# Placeholder function, all ghosts have their own logic for chasing pacman.
func _get_chase_target() -> Vector2:
	return _pacman.position

# When frightened, ghost will calculate a position away from pacman.
func _get_frightened_target() -> Vector2:
	return position + (position - _pacman.position)
	
func _update_state(delta) -> void:
	if state == State.CHASE:
		_chase_timer += delta
		if _chase_timer >= chase_duration:
			_chase_timer = 0.0
			state = State.SCATTER
	elif state == State.SCATTER:
		_scatter_timer += delta
		if _scatter_timer >= scatter_duration:
			_scatter_timer = 0.0
			state = State.CHASE
	
