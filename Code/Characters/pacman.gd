class_name Pacman extends CharacterBody2D

@export var _respawn_point : Node2D
@export var speed : float = 120
@onready var _animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D

const TILE_SIZE : int = 16

var direction : Vector2 = Vector2.RIGHT
var next_direction : Vector2 = Vector2.RIGHT


func _ready() -> void:
	# Snaps pacman into the closest 16x16 tile to make grid movement possible. 
	position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))

func _physics_process(_delta: float) -> void:
	_read_input()
	_move()
	_update_rotation()
	# TODO: _update_animations()

#region Internal Functionality	
func _read_input() -> void:
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
	# Error-tolerance of 2 pixels.
	return (x_remainder < 2.0 or x_remainder > TILE_SIZE - 2.0) and \
		   (y_remainder < 2.0 or y_remainder > TILE_SIZE - 2.0)

func _is_direction_blocked(dir: Vector2) -> bool:
	var collision = move_and_collide(dir * TILE_SIZE, true)
	# true = direction is blocked
	# false = direction is not blocked
	return collision != null

func _move() -> void:
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
		_animated_sprite_2d.rotation = 0
		_animated_sprite_2d.flip_h = false
	elif direction == Vector2.LEFT:
		_animated_sprite_2d.rotation = 0
		_animated_sprite_2d.flip_h = true
	elif direction == Vector2.UP:
		_animated_sprite_2d.rotation = -PI / 2
		_animated_sprite_2d.flip_h = false
	elif direction == Vector2.DOWN:
		_animated_sprite_2d.rotation = PI / 2
		_animated_sprite_2d.flip_h = false
#endregion

#func _update_animation() -> void:
#func die()
