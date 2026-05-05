class_name PauseMenu extends Control

var _is_open: bool = false

func _ready() -> void:
	hide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if _is_open:
			close()
		else:
			open()

func open() -> void:
	_is_open = true
	pause()
	show()
	
func close() -> void:
	_is_open = false
	resume()
	hide()
	
# TODO: GameManageriin "scene_tree" luotava, että toimii
func pause() -> void:
	GameManager.get_scene_tree().paused = true

func resume() -> void:
	GameManager.get_scene_trene().pause = false

func _on_ok_pressed() -> void:
	# TODO: Tallenna asetukset
	close()


func _on_cancel_pressed() -> void:
	close()
