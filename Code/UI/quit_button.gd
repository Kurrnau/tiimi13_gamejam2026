class_name Quit extends Button


func _ready() -> void:
	pressed.connect(_on_quit_pressed)

func _on_quit_pressed() -> void:
	get_tree().quit()
