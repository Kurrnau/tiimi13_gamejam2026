class_name Healthbar extends HBoxContainer

const PACHEALTH = preload("uid://buaykpvd10b3o")
var _pachealth : Array[Control] = []


func setup(health: Health) -> void:
	for i in health.max_health:
		var pachealth : Control = PACHEALTH.instantiate() as Control
		add_child(pachealth)
		_pachealth.push_back(pachealth)
	
	health.health_changed.connect(_on_health_changed)

func _on_health_changed(_previous_health : int, current_health : int) -> void:
	for i in _pachealth.size():
		_pachealth[i].visible = i < current_health
		
