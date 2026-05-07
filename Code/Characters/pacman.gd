class_name Pacman extends CharacterBody2D

@export var _respawn_point : Node2D
@export var speed : float = 100
@onready var _animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Node = $Health


const TILE_SIZE : int = 16

var movement_enabled: bool = false
var direction : Vector2 = Vector2.RIGHT
var next_direction : Vector2 = Vector2.RIGHT
var _invincible: bool = false


func _ready() -> void:
	# Snaps pacman into the closest 16x16 tile to make grid movement possible. 
	position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))

func _physics_process(_delta: float) -> void:
	_read_input()
	_move()
	_update_rotation()

#region Internal Functionality	
func _read_input() -> void:
	if not movement_enabled:
		if Input.is_action_just_pressed("Right") or Input.is_action_just_pressed("Left") or \
		   Input.is_action_just_pressed("Up") or Input.is_action_just_pressed("Down"):
			movement_enabled = true
	if Input.is_action_pressed("Right"):
		next_direction = Vector2.RIGHT
	elif Input.is_action_pressed("Left"):
		next_direction = Vector2.LEFT
	elif Input.is_action_pressed("Up"):
		next_direction = Vector2.UP
	elif Input.is_action_pressed("Down"):
		next_direction = Vector2.DOWN

func _is_on_grid() -> bool:
	# Calculates pacman's position to make sure it's within the 16x16 grid.
	var x_remainder = fmod(position.x, TILE_SIZE)
	var y_remainder = fmod(position.y, TILE_SIZE)
	# Error-tolerance of 1 pixel.
	return (x_remainder < 1.0 or x_remainder > TILE_SIZE - 1.0) and \
		   (y_remainder < 1.0 or y_remainder > TILE_SIZE - 1.0)

func _is_direction_blocked(dir: Vector2) -> bool:
	var collision = move_and_collide(dir * TILE_SIZE, true)
	# true = direction is blocked
	# false = direction is not blocked
	return collision != null

func _move() -> void:
	if not movement_enabled:
		return
	if _is_on_grid():
		position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))
		if not _is_direction_blocked(next_direction):
			direction = next_direction
		if _is_direction_blocked(direction):
			velocity = Vector2.ZERO
			return
	velocity = direction * speed
	move_and_slide()

func _update_rotation() -> void:
	if direction == Vector2.RIGHT:
		_animated_sprite_2d.rotation_degrees = 0
		_animated_sprite_2d.flip_h = false
	elif direction == Vector2.LEFT:
		_animated_sprite_2d.rotation_degrees = 0
		_animated_sprite_2d.flip_h = true
	elif direction == Vector2.UP:
		_animated_sprite_2d.rotation_degrees = -90
		_animated_sprite_2d.flip_h = false
	elif direction == Vector2.DOWN:
		_animated_sprite_2d.rotation_degrees = 90
		_animated_sprite_2d.flip_h = false
#endregion

func take_hit() -> void:
	if _invincible:
		return
	_invincible = true
	health.take_damage(1)
	await get_tree().create_timer(2.0).timeout
	_invincible = false

func _on_health_changed(_previous_health: int, current_health: int) -> void:
	if current_health <= 0:
		_die()
		
func respawn() -> void:
	_animated_sprite_2d.play("chomp")
	position = _respawn_point.global_position
	position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))
	direction = Vector2.RIGHT
	next_direction = Vector2.RIGHT
	velocity = Vector2.ZERO
	
func _die() -> void:
	movement_enabled = false
	velocity = Vector2.ZERO
	
	await get_tree().create_timer(1.5).timeout
	
	GameManager.restart_game()
