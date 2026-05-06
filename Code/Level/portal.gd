class_name Portal extends Area2D

@export var destination_portal: Portal
@export var teleport_offset: Vector2 = Vector2(32, 0)
#ExitLeft -> drag and drop ExitRight -> -32
#ExitRight -> drag and drop ExitLeft -> 32 (default)

# Prevent infinite loops
var _recently_teleported: Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Ignore if no destination set
	if not destination_portal:
		return
	# Prevent infinite teleport loop
	if body in _recently_teleported:
		return
	# Teleport!
	body.global_position = destination_portal.global_position + teleport_offset
	
	# Mark as teleported in BOTH portals
	_recently_teleported.append(body)
	destination_portal._recently_teleported.append(body)
	# Clear the flag after a brief delay
	await get_tree().create_timer(0.2).timeout
	_recently_teleported.erase(body)
	destination_portal._recently_teleported.erase(body)
