class_name Collectable extends Area2D

var is_collected : bool = false

func _on_body_entered(body : Node2D) -> void:
	print("Something collided with a collectable") 	#TEST
	if body is Pacman:
		if not collect(body as Pacman):
			push_warning("Collectable: Collecting didn't succeed!")

func collect(body : Pacman) -> bool:
	if is_collected:
		return false
	
	is_collected = true
	clear()
	return true

func clear() -> void:
	queue_free()
