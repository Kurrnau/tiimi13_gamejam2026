class_name Dot extends Collectable

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var _score: int = 10


func collect(pacman : Pacman) -> bool:
	if not super.collect(pacman):
		return false
		
	GameManager.add_score(_score)
	return true

func clear() -> void:
	if audio_stream_player_2d == null:
		super.clear()
		return
		
	hide()
	audio_stream_player_2d.play()
	audio_stream_player_2d.finished.connect(_on_effect_finished)
		
func _on_effect_finished() -> void:
	queue_free()
