class_name QuitToStart extends Button

func _ready() -> void:
	pressed.connect(_on_quit_to_start_pressed)

func _on_quit_to_start_pressed() -> void:
	GameManager.reset()
	GameManager.go_to_scene("res://Scenes/Levels/start_screen.tscn")
	
