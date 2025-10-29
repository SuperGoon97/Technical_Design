@tool 

extends Sprite2D

var base_scale:Vector2 = Vector2(0.5,0.5)
var viewport:Viewport = null
@export var advanced_camera_target_parent:AdvancedCameraTarget = null:
	set(value):
		advanced_camera_target_parent = value
		if !advanced_camera_target_parent.draw_camera_icon_changed.is_connected(update_visibilty):
			advanced_camera_target_parent.draw_camera_icon_changed.connect(update_visibilty)

func _ready() -> void:
	if Engine.is_editor_hint():
		visible = true
	else:
		visible = false

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if viewport == null:
			viewport = get_viewport()
		update_scale()

func update_scale():
	if viewport == null:
		viewport = get_viewport()
	var viewport_scale = viewport.get_final_transform().x.x
	scale = Vector2(clampf(base_scale.x * (1.0/viewport_scale),0.01,2.0),clampf(base_scale.y * (1.0/viewport_scale),0.01,2.0))

func update_visibilty(state:bool):
	print("try update")
	visible = state
