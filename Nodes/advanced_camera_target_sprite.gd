@tool 

extends Sprite2D

var base_scale:Vector2 = Vector2(0.5,0.5)
var viewport:Viewport = null

func _ready() -> void:
	if Engine.is_editor_hint():
		visible = true
	else:
		visible = false

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if viewport == null:
			viewport = get_viewport()
		update_scale()

func update_scale():
	if viewport == null:
		viewport = get_viewport()
	var viewport_scale = viewport.get_final_transform().x.x
	scale = Vector2(clampf(base_scale.x * (1.0/viewport_scale),0.01,2.0),clampf(base_scale.y * (1.0/viewport_scale),0.01,2.0))

func _on_advanced_camera_target_draw_camera_icon_changed(state: bool) -> void:
	visible = state
