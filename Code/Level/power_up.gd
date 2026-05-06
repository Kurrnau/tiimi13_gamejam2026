class_name PowerUp extends Collectable #Area2D

signal powerup_eaten					#TEST

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var _score: int = 50

func collect(pacman : Pacman) -> bool:
	if not super.collect(pacman):
		return false
	
	GameManager.add_score(_score)
	_on_powerup_eaten()					#TEST

	return true

func _on_powerup_eaten():				#TEST
	emit_signal("powerup_eaten")
	
func clear() -> void:
	if audio_stream_player_2d == null:
		super.clear()
		return
		
	hide()
	audio_stream_player_2d.play()
	audio_stream_player_2d.finished.connect(_on_effect_finished)
		
func _on_effect_finished() -> void:
	queue_free()
