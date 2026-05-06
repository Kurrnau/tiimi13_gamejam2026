class_name AudioControl extends VBoxContainer

@onready var bus_name_label: Label = $Label
@onready var volume_slider: HSlider = $HSlider
@export var audio_bus_name: StringName = ""

var _bus_index : int = -1

func _ready() -> void:
	if _bus_index < 0:
		_bus_index = AudioServer.get_bus_index(audio_bus_name);
		
	if _bus_index < 0:
		push_error("Can't find audio bus with the name %s" % audio_bus_name)
		return
		
	bus_name_label.text = audio_bus_name
		
	_update_slider()
	volume_slider.value_changed.connect(_on_volume_changed)
	
func _update_slider() -> void:
	var db_volume :float = AudioServer.get_bus_volume_db(_bus_index)
	var linear_volume : float = db_to_linear(db_volume)
	volume_slider.value = linear_volume
	
func _on_volume_changed(linear_volume: float) -> void:
	var db_volume : float = linear_to_db(linear_volume)
			
	AudioServer.set_bus_volume_db(_bus_index, db_volume)
