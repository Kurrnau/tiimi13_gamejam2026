class_name StartScreen extends Control

@onready var start_button = $"menu-buttons/start-button"
@onready var quit_button = $"menu-buttons/quit-button"

func _ready() -> void:
	# Make sure, the buttons exist.
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	GameManager.reset()
	GameManager.go_to_scene(GameManager._level_paths[0])

func _on_quit_pressed() -> void:
	get_tree().quit()
