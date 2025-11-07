extends VisibleOnScreenNotifier2D

@onready var advanced_camera_target: AdvancedCameraTarget = $AdvancedCameraTarget

@onready var advanced_camera_target_2: AdvancedCameraTarget = $AdvancedCameraTarget2
func _on_screen_entered() -> void:
	advanced_camera_target.execute_actions()


func _on_screen_exited() -> void:
	advanced_camera_target_2.execute_actions()
	pass # Replace with function body.
