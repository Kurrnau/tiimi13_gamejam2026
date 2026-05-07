class_name Collectable extends Area2D

signal collected(collectable: Collectable)

var is_collected : bool = false

func _on_body_entered(body : Node2D) -> void:
	print("Something collided with a collectable") 	#TEST
	if body is Pacman:
		if not collect(body as Pacman):
			print("Collectable: Collecting didn't succeed, probably Ghost!")

func collect(_pacman : Pacman) -> bool:
	if is_collected:
		return false
	
	is_collected = true
	collected.emit(self)
	clear()
	return true
	
func clear() -> void:
	queue_free()
