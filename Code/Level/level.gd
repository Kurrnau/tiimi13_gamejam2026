class_name Level extends Node2D

@onready var pacman: Pacman = $Pacman
@onready var healthbar: Healthbar = $GameData/Healthbar


#spawn_point?

func _ready() -> void:
	GameManager.register_current_level(self)
	healthbar.setup(pacman.health)
	#spawnpoint?

#func spawnpoint()?
