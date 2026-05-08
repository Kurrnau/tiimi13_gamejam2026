class_name Health extends Node

signal health_changed(previous_health: int, current_health: int)
@onready var pacman: Pacman = $".."
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"

@export var max_health : int = 4
var _current_health : int = 0
 

func _ready() -> void:
	reset()

func get_current_health() -> int:
	return _current_health
	
func set_current_health(value: int) -> void:
	var previous_health: int = _current_health
	_current_health = clamp(value, 0, max_health)
	health_changed.emit(previous_health, _current_health)
	
func take_damage(amount: int) -> bool:
	if amount < 0:
		return false
	animated_sprite_2d.play("take_damage")
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	
	set_current_health(_current_health - amount)
	return true

func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "take_damage":
		animated_sprite_2d.play("chomp")
		animated_sprite_2d.animation_finished.disconnect(_on_animation_finished)

func heal(amount: int) -> bool:
	if amount < 0:
		return false
	if _current_health >= max_health:
		return false
	set_current_health(_current_health + amount)
	return true

func reset() -> void:
	set_current_health(max_health)
