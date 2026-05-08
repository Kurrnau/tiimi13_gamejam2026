class_name MusicManager extends Node

@onready var intro_player: AudioStreamPlayer = $IntroPlayer
@onready var music_player: AudioStreamPlayer = $BackgroundMusic
@onready var power_up_player: AudioStreamPlayer = $PowerUpPlayer

var is_powerup_active: bool = false

func _ready() -> void:
	# Kuunnellaan GameManagerin signaalia
	GameManager.powerup_triggered.connect(_on_powerup_tiggered)
	# Varmistetaan, että kuunnellaan milloin intro loppuu
	intro_player.finished.connect(_on_intro_finished)
	
	# Jos haluat varmistaa käynnistyksen koodilla:
	if not intro_player.playing:
		intro_player.play()

func _on_intro_finished() -> void:
	# Intro loppui, aloitetaan varsinainen looppaava musiikki
	music_player.play()

func start_power_up_music() -> void:
	is_powerup_active = true
	music_player.stream_paused = true
	power_up_player.play()
	
func end_power_up_music() -> void:
	is_powerup_active = false
	if power_up_player.playing:
		power_up_player.stop()
		
	music_player.stream_paused = false

func _on_powerup_tiggered(duration: float) -> void:
	start_power_up_music()
	await get_tree().create_timer(duration).timeout
	end_power_up_music()
	
func sync_music_after_pause() -> void:
	if is_powerup_active:
		music_player.stream_paused = true
		if not power_up_player.playing:
			power_up_player.play()
	else:
		power_up_player.stop()
		music_player.stream_paused = false
		
