@tool 

extends Sprite2D

func _ready() -> void:
	if Engine.is_editor_hint():
		visible = true
	else:
		visible = false


func _on_advanced_camera_target_draw_camera_icon_changed(state: bool) -> void:
	visible = state
