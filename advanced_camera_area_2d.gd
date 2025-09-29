class_name AdvancedCameraArea2D extends Area2D

@export_category("AreaDefaults")
@export var is_player_area:bool = false

func _on_area_entered(area: Area2D) -> void:
	var advanced_camera_area_2d := area as AdvancedCameraArea2D
	if advanced_camera_area_2d:
		print("is advancedcamarea2d")
