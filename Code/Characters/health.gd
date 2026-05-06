class_name Health extends Node

signal health_changed(previous_health: int, current_health: int)

@export var max_health : int = 5

var _current_health : int = 0
var is_immortal : bool = false
 

func _ready() -> void:
	reset()

func is_alive() -> bool:
	return _current_health > 0

func get_current_health() -> int:
	return _current_health
	
func set_current_health(value: int) -> void:
	var previous_health: int = _current_health
	_current_health = clamp(value, 0, max_health)
	health_changed.emit(previous_health, _current_health)
	
func take_damage(amount: int) -> bool:
	if amount < 0:
		return false
	set_current_health(_current_health - amount)
	return true

func heal(amount: int) -> bool:
	if amount < 0:
		return false
	set_current_health(_current_health + amount)
	return true

func reset() -> void:
	set_current_health(max_health)
