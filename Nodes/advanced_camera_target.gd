@tool
class_name AdvancedCameraTarget extends Node2D

signal draw_camera_icon_changed(state:bool)
const NEXA_CUSTOM_FONT = preload("res://nexa_custom_font.tres")

@export_tool_button("Force Update","Callable") var force_update = update_one_over_camera_zoom

@export var _draw_viewport_rect:bool = true
@export var _draw_camera_icon:bool = true:
	get:
		return _draw_camera_icon
	set(value):
		draw_camera_icon_changed.emit(value)
		_draw_camera_icon = value
@export var _draw_color:Color = Color.WHITE
@export_custom(PROPERTY_HINT_LINK,"") var camera_zoom_at_target:Vector2 = Vector2(1.0,1.0):
	get:
		return camera_zoom_at_target
	set(value):
		update_one_over_camera_zoom()
		camera_zoom_at_target = value

var camera_line:ToolLine2D
var one_over_camera_zoom:Vector2
var target_parent:Node2D
var screen_position:Vector2
var half_viewport_x:float
var half_viewport_y:float

func _draw() -> void:
	if _draw_viewport_rect:
		draw_viewport_rect()

## Draws the area the viewport will use, also draws the text above the box
func draw_viewport_rect():
	if !half_viewport_x:
		half_viewport_x = (ProjectSettings.get_setting("display/window/size/viewport_width"))/2.0
		half_viewport_y = (ProjectSettings.get_setting("display/window/size/viewport_height"))/2.0
	
	if !one_over_camera_zoom:
		update_one_over_camera_zoom()
	
	var dx = Vector2(half_viewport_x*one_over_camera_zoom.x,half_viewport_y*one_over_camera_zoom.y)
	var dxx = Vector2(-half_viewport_x*one_over_camera_zoom.x,half_viewport_y*one_over_camera_zoom.y)
	var dy = Vector2(half_viewport_x*one_over_camera_zoom.x,-half_viewport_y*one_over_camera_zoom.y)
	var dyy = Vector2(-half_viewport_x*one_over_camera_zoom.x,-half_viewport_y*one_over_camera_zoom.y)

	draw_line(dx,dy,_draw_color)
	draw_line(dxx,dyy,_draw_color)
	draw_line(dxx,dx,_draw_color)
	draw_line(dyy,dy,_draw_color)
	
	draw_string(NEXA_CUSTOM_FONT,Vector2(-75.0,-(half_viewport_y*1.01)),"VIEWPORT SIZE")

## Creates the tool line 2d and adds it as a child (could also use a viewport draw instead)
func setup():
	camera_line = ToolLine2D.new()
	add_child(camera_line)
	camera_line.width = 2.0
	camera_line.global_position = Vector2(0,0)
	camera_line.add_point(global_position,0)
	camera_line.add_point(target_parent.position,1)

func update_one_over_camera_zoom():
	one_over_camera_zoom = Vector2(1.0/camera_zoom_at_target.x,1.0/camera_zoom_at_target.y)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		if camera_line:
			if camera_line.points.size() == 2:
				camera_line.global_position = Vector2(0,0)
				camera_line.set_point_position(0,global_position)
				camera_line.set_point_position(1,target_parent.position)


func _on_property_list_changed() -> void:
	update_one_over_camera_zoom()
