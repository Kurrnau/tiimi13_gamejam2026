extends Node 

# Signals
signal score_changed(new_score : int)
signal level_changed(level_number: int)

# Player's score and health in this session
var _score : int = 0
var _current_level : Level = null
var _scene_tree : SceneTree = null
var _current_level_number: int = 1

#region Array of level paths
var _level_paths: Array[String] = [
	"res://Scenes/Levels/level_1.tscn",
	"res://Scenes/Levels/level_2.tscn",
	"res://Scenes/Levels/level_3.tscn"
	# Add more levels as you create them
]

#endregion

#region Score
func reset() -> void:
	set_score(0)
	_current_level_number = 1

func add_score(amount : int) -> void:
	if amount > 0:
		set_score(_score + amount)
	
func get_score() -> int:
	return _score
	
func set_score(new_score : int) -> void:
	_score = max(new_score, 0)
	score_changed.emit(_score)

#endregion 
	
#region Level functionality
func get_scene_tree() -> SceneTree:
	if _scene_tree == null:
		_scene_tree = get_tree()
	return _scene_tree

func get_current_level() -> Level:
	return _current_level

func register_current_level(new_level: Level) -> void:
	if _current_level == null:
		_current_level = new_level	
		if _current_level.has_signal("level_completed"): #ADDITION
			_current_level.level_completed.connect(_on_level_completed)

func _on_level_completed() -> void:
	print("GameManager: Level %d completed!" % _current_level_number)
	# You could add victory screen, stats, etc. here

func next_level() -> void:
	_current_level_number += 1
	# Check if there are more levels
	if _current_level_number - 1 < _level_paths.size():
		var next_path = _level_paths[_current_level_number - 1]
		print("Loading level %d: %s" % [_current_level_number, next_path])
		go_to_scene(next_path)
		level_changed.emit(_current_level_number)
	else:
		_show_victory()

func _show_victory() -> void:
	print("GameManager: GAME COMPLETED! Final score: %d" % _score)
	var victory_path = "res://Scenes/Levels/final.tscn"
	if ResourceLoader.exists(victory_path):
		print("GameManager: Loading victory scene: %s" % victory_path)
		go_to_scene(victory_path)
	else:
		print("GameManager: No victory scene found, restarting game")
		restart_game()

func restart_game() -> void:
	reset()
	go_to_scene(_level_paths[0])
		
func go_to_scene(scene_path: String) -> void:
	_load_scene.call_deferred(scene_path)

func _load_scene(scene_path: String) -> void:
	if _current_level != null:
		# Disconnect signal before freeing
		if _current_level.level_completed.is_connected(_on_level_completed):
			_current_level.level_completed.disconnect(_on_level_completed)
		# Delete the current level from memory
		_current_level.free()
		_current_level = null	# CRITICAL: Set to null so register_current_level works

	
	var next_scene: PackedScene = ResourceLoader.load(scene_path) as PackedScene
	if next_scene != null:
		_current_level = next_scene.instantiate() as Level
	else:
		push_error("GameManager: Failed to load a scene in the path %s" % scene_path)
		return

	if _scene_tree == null:
		_scene_tree = get_tree()
	
	if _scene_tree != null:
		_scene_tree.root.add_child(_current_level)
		_scene_tree.current_scene = _current_level
	
#endregion
