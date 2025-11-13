extends Node
@export var first_camera_target:AdvancedCameraTarget

func _ready() -> void:
	if first_camera_target:
		first_camera_target.execute_actions()
