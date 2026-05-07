class_name Restart extends Button

@onready var restart_button: Button = $"."

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)

func _on_restart_pressed() -> void:
	GameManager.restart_game()
