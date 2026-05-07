class_name MusicManager extends Node

@onready var intro_player: AudioStreamPlayer = $IntroPlayer
@onready var music_player: AudioStreamPlayer = $BackgroundMusic

# Tarkista signaalit. Ovat nyt liitettynä test_level.tscn.

func _ready() -> void:
	# Varmistetaan, että kuunnellaan milloin intro loppuu
	intro_player.finished.connect(_on_intro_finished)
	
	# Jos haluat varmistaa käynnistyksen koodilla:
	if not intro_player.playing:
		intro_player.play()

func _on_intro_finished() -> void:
	# Intro loppui, aloitetaan varsinainen looppaava musiikki
	music_player.play()
	print("Intro ohi, musiikki alkaa.")
