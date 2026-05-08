class_name PowerUp extends Collectable

signal powerup_eaten

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var _score: int = 50
var heal_amount: int = 1


func collect(pacman : Pacman) -> bool:
	if not super.collect(pacman):
		return false
	pacman.health.heal(heal_amount)
	GameManager.add_score(_score)
	GameManager.powerup_triggered.emit(9.0)
	_on_powerup_eaten()
	return true

func _on_powerup_eaten():
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
