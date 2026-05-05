extends Node 

# Signals
signal score_changed(new_score : int)

# Player's score and health in this session
var _score : int = 0

func reset() -> void:
	set_score(0)

#region Score
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
