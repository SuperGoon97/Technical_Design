@tool
class_name AdvancedCameraTarget extends Node2D

## Emitted when the camera has arrived this target
@warning_ignore("unused_signal")
signal camera_at_target
## Emitted when draw camera icon bool is changed, informs sprite to toggle visibility
signal draw_camera_icon_changed(state:bool)
const NEXA_CUSTOM_FONT = preload("res://nexa_custom_font.tres")

@export_tool_button("Force Update","Callable") var force_update = update_one_over_camera_zoom
@export var target_function:G_Advanced_Cam.TARGET_FUNCTION = G_Advanced_Cam.TARGET_FUNCTION.MOVE_TO:
	get:
		return target_function
	set(value):
		target_function = value
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

## Contains values used if Target Function is set to "Move To"
@export_subgroup("Move To")
## How long the camera will take to reach the target, if camera speed is a positive value this will be ignored
@export_range(0.0,100.0,0.1) var time_to_reach_target:float = 1.0
## If camera speed is a positive value time to reach target will be ignored and the camera will move a flat speed instead
@export_range(-1.0,500.0,1.0) var camera_max_speed:float = -1.0
## How quickly the camera will achieve max speed
@export_range(0.0,100.0,0.1) var camera_acceleration_speed:float = 0.0
## How long the camera will be held at location for before moving on
@export var allow_overshoot:bool = false
@export_custom(PROPERTY_HINT_RANGE,"0.0,100.0,0.1,suffix:s") var hold_camera_for:float = 0.0
## Hold the camera until told otherwise, use this to hold the camera in a position until you have finished showing the player something.
## You can see when the camera is at target area with the signal [signal AdvancedCameraTarget.camera_at_target].
## Can be used in conjunction with hold_camera_for, camera will await move_camera_on then start the hold timer.
## [codeblock]
## func show_player_text()
## display_story_function()
## await text_finished
## G_Advanced_Cam.move_camera_on.emit()
## return
@export var hold_camera_indefinitely:bool = false
## Which easing to use for the camera "Move To"
@export var tween_easing:Tween.EaseType = Tween.EaseType.EASE_IN_OUT

var camera_line:ToolLine2D
var one_over_camera_zoom:Vector2
@export_custom(PROPERTY_HINT_NODE_TYPE,"Node2D",PROPERTY_USAGE_STORAGE) var target_parent:Node2D
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
	camera_line.add_point(target_parent.global_position,1)

func update_one_over_camera_zoom():
	one_over_camera_zoom = Vector2(1.0/camera_zoom_at_target.x,1.0/camera_zoom_at_target.y)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		if camera_line:
			if camera_line.points.size() == 2:
				camera_line.global_position = Vector2(0,0)
				camera_line.set_point_position(0,global_position)
				camera_line.set_point_position(1,target_parent.global_position)
