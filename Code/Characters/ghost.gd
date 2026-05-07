class_name Ghost extends CharacterBody2D

enum State { WAITING, CHASE, SCATTER, FRIGHTENED, FLASHING, LEAVING_HOME, EATEN }

@export var scatter_target: Vector2

@export var normal_speed: float = 90.0
@export var frightened_speed: float = 50.0
@export var eaten_speed: float = 160.0

@export var home_exit: Vector2 = Vector2(320, 168)
@export var home_center: Vector2 = Vector2(320, 203)

@export var leaving_home_timer: float = 0.0
@export var frightened_duration: float = 7.0


@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#How the ghosts find pacman's position:
@onready var _pacman: Pacman = get_tree().get_first_node_in_group("pacman")

const TILE_SIZE: int = 16

var _debug_timer: float = 0.0

var speed: float = 90.0
var state: State = State.CHASE
var direction: Vector2 = Vector2.LEFT

func _ready() -> void:
	position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))
	state = State.WAITING
	# Connect to all powerups in the scene
	for powerup in get_tree().get_nodes_in_group("powerups"):
		powerup.powerup_eaten.connect(_on_powerup_eaten)
	GameManager.chase_started.connect(_on_chase_started)
	GameManager.scatter_started.connect(_on_scatter_started)
	await get_tree().create_timer(leaving_home_timer).timeout
	state = State.LEAVING_HOME

func _physics_process(delta: float) -> void:
	_update_state(delta)
	_move()
	_check_pacman_collision()
	_update_animations()

#region Ghost movement	
# Movement on the 16x16 grid (same as pacman).
func _move() -> void:
	if state == State.WAITING:
		return
	if state == State.EATEN:
		if position.distance_to(home_center) < TILE_SIZE * 2:
			_respawn_ghost()
			return
		if _is_on_grid():
			print(name, " EATEN not on grid: ", position)
			direction = _get_best_direction(_get_target())
		velocity = direction * speed
		move_and_slide()
		return
	if state == State.LEAVING_HOME:
		direction = Vector2.UP
		velocity = Vector2(0, -speed)
		move_and_slide()
		if position.y <= home_exit.y:
			position.y = home_exit.y
			state = State.CHASE
		return
	if _is_on_grid(): 
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
		if state != State.EATEN and position.y >= home_exit.y - TILE_SIZE * 4 and position.x > 284 and position.x < 356 and dir == Vector2.DOWN:
			continue
		# Prevent ghosts from using portals
		var check_pos = position + dir * TILE_SIZE
		var portals = get_tree().get_nodes_in_group("portals")
		var portal_nearby = false
		for portal in portals:
			if check_pos.distance_to(portal.global_position) < TILE_SIZE * 2:
				portal_nearby = true
				break
		if portal_nearby:
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

#region Ghost Targeting
func _get_target() -> Vector2:
	match state:
		State.EATEN:
			if position.distance_to(home_exit) > TILE_SIZE * 2:
				return home_exit
			else:
				return home_center
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
	
#endregion
	
func _update_state(delta) -> void:
	_debug_timer += delta
	if _debug_timer >= 1.0:
		_debug_timer = 0.0
		print(name, " state: ", state)
	_update_speed()
	_update_speed()

func _update_speed() -> void:
	match state:
		State.FRIGHTENED, State.FLASHING:
			speed = frightened_speed
		State.EATEN:
			speed = eaten_speed
		_:
			speed = normal_speed

func _update_animations() -> void:
	var dir_suffix: String
	if direction == Vector2.RIGHT:
		dir_suffix = "_right"
	elif direction == Vector2.LEFT:
		dir_suffix = "_left"
	elif direction == Vector2.UP:
		dir_suffix = "_up"
	elif direction == Vector2.DOWN:
		dir_suffix = "_down"
		
	match state:
		State.FRIGHTENED:
			_animated_sprite_2d.play ("frightened" + dir_suffix)
		State.EATEN:
			_animated_sprite_2d.play ("eaten" + dir_suffix)
		State.FLASHING:
			_animated_sprite_2d.play("flashing" + dir_suffix)
		_:
			_animated_sprite_2d.play("looking" + dir_suffix)

func _respawn_ghost() -> void:
	position = home_center
	state = State.WAITING
	await get_tree().create_timer(leaving_home_timer).timeout
	state = State.LEAVING_HOME

func _on_powerup_eaten() -> void:
	state = State.FRIGHTENED
	await get_tree().create_timer(frightened_duration).timeout
	if state == State.FRIGHTENED:
		state = State.FLASHING
	await get_tree().create_timer(2.0).timeout
	if state == State.FLASHING:
		state = State.CHASE

func _on_body_entered(body: Node2D) -> void:
	print("body entered: ", body)
	if body is Ghost:
		return
	if body is Pacman:
		if state == State.FRIGHTENED or state == State.FLASHING:
			state = State.EATEN
		elif state == State.CHASE or state == State.SCATTER:
			body.die()

func _check_pacman_collision() -> void:
	if _pacman and position.distance_to(_pacman.position) < TILE_SIZE / 2:
		if state == State.FRIGHTENED or state == State.FLASHING:
			state = State.EATEN
		elif state == State.CHASE or state == State.SCATTER:
			_pacman.die()

#region Ghost Timers
func _on_chase_started() -> void:
	if state != State.FRIGHTENED and state != State.FLASHING and state != State.EATEN:
		state = State.CHASE

func _on_scatter_started() -> void:
	if state != State.FRIGHTENED and state != State.FLASHING and state != State.EATEN:
		state = State.SCATTER
#endregion
