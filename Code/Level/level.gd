class_name Level extends Node2D

signal level_completed

@onready var pacman: Pacman = $Pacman
@onready var healthbar: Healthbar = $GameData/Healthbar

var _total_collectables: int = 0
var _collected_count: int = 0

func _ready() -> void:
	GameManager.register_current_level(self)
	healthbar.setup(pacman.health)
	_setup_collectables()

func _setup_collectables() -> void:
	# Get all nodes that are collectables (dots + powerups)
	var collectables = get_tree().get_nodes_in_group("collectables")
	_total_collectables = collectables.size()
	print("Level: Found %d collectables" % _total_collectables)
	# Connect to each collectable's signal
	for collectable in collectables:
		if collectable is Collectable:
			collectable.collected.connect(_on_collectable_collected)

func _on_collectable_collected(_collectable: Collectable) -> void:
	_collected_count += 1
	print("Collected: %d/%d" % [_collected_count, _total_collectables])
	# Check win condition
	if _collected_count >= _total_collectables:
		_on_level_completed()

func _on_level_completed() -> void:
	print("Level completed!")
	level_completed.emit()
	# Optional: Add delay before transition
	await get_tree().create_timer(0.5).timeout
	GameManager.next_level()
