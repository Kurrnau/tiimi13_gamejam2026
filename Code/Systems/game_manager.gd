extends Node 

# Signals
signal score_changed(new_score : int)

# Player's score and health in this session
var _score : int = 0
var _current_level : Level = null
var _scene_tree : SceneTree = null


#region Score
func reset() -> void:
	set_score(0)

func add_score(amount : int) -> void:
	if amount > 0:
		set_score(_score + amount)
	
func get_score() -> int:
	return _score
	
func set_score(new_score : int) -> void:
	_score = max(new_score, 0)
	score_changed.emit(_score)
	
	print("Score: %s" % _score) 					#TEST This line is for debugging
#endregion 

func get_scene_tree() -> SceneTree:
	if _scene_tree == null:
		_scene_tree = get_tree()
	return _scene_tree
	
#region Level functionality
func get_current_level() -> Level:
	return _current_level

func register_current_level(new_level: Level) -> void:
	if _current_level == null:
		_current_level = new_level
		
func go_to_scene(scene_path: String) -> void:
	_load_scene.call_deferred(scene_path)

func _load_scene(scene_path: String) -> void:
	if _current_level != null:
		# Delete the current level from memory
		_current_level.free()
	
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
