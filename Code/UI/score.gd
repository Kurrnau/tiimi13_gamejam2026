class_name Score extends Label


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	_on_score_changed(GameManager.get_score())

func _on_score_changed(score: int) -> void:
	text = "Score: %s" % score
