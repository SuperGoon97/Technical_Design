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
## Moves the camera by changing the camera target to this target
@export var move_by_change_target:bool = false
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
## Releases the camera assigning the target of the camera back to the default camera target
@export var release_camera_back_to_default_after_hold:bool = true
## How long the camera will take to reach the target, if camera speed is a positive value this will be ignored
@export_range(0.0,100.0,0.1) var time_to_reach_target:float = 1.0
## How long the camera will be held at location for before moving on
@export_custom(PROPERTY_HINT_RANGE,"0.0,100.0,0.1,suffix:s") var hold_camera_for:float = 0.0
## Which easing to use for the camera "Move To"
@export var tween_easing:Tween.EaseType = Tween.EaseType.EASE_IN_OUT

## Contains values used if Target Function is set to "Stay In Area"
@export_subgroup("Stay In Area")
## Controls the north bound for the camera
@export_range(0.0,100.0,1.0,"or_greater","hide_slider") var north_bound:float = 0.0:
	set(value):
		north_bound = value
		update_packed_bound_array()
## Controls the south bound for the camera
@export_range(0.0,100.0,1.0,"or_greater","hide_slider") var south_bound:float = 0.0:
	set(value):
		south_bound = value
		update_packed_bound_array()
## Controls the east bound for the camera
@export_range(0.0,100.0,1.0,"or_greater","hide_slider") var east_bound:float = 0.0:
	set(value):
		east_bound = value
		update_packed_bound_array()
## Controls the west bound for the camera
@export_range(0.0,100.0,1.0,"or_greater","hide_slider") var west_bound:float = 0.0:
	set(value):
		west_bound = value
		update_packed_bound_array()
@export var teleport_camera_to_nearest_point_in_bounds:bool = false

enum MULTI_TARGET_MODE{
	## Adds the multi target dict to current camera multi targets
	ADD,
	## Sets the cameras multi target dict to this
	SET,
}
@export_subgroup("Multi Target")
## Changes if multi target mode should be used by the camera
@export var camera_use_multi_target:bool = true
## Changes how the multi target dict is used, see ENUM for uses
@export var multi_target_mode:MULTI_TARGET_MODE = MULTI_TARGET_MODE.ADD
## Multi target dict with Node2D targets and float weights, weights are used to indicate how much pull the target should have on the camera
@export var multi_targets:Dictionary[Node2D,float] = {}

enum STRENGTH_MODE{
	## Adds strength to the current camera shake strength
	ADD,
	## Sets the cameras shake strength
	SET,
}
@export_subgroup("Shake")
## If true the camera will be told to stop shaking indefinitely, the rest of the properties are ignored from this action
@export var stop_shake:bool = false
## Amplitude is the base for the shake
@export_range(0.0,100.0,1.0,"or_greater") var amplitude:float = 40.0
## Changes if strength will be added or set, adding strength can get very shakey very quickly. Note all other properties are treat as set
@export var strength_mode:STRENGTH_MODE = STRENGTH_MODE.SET
## Strength is the multiplier for the amplitude, it decays as the shake progresses
@export_range(1.0,10.0,0.1,"or_greater") var strength:float = 1.0
## Strength power is the amount strengh is pow() by
## [codeblock]
## func _foo() -> float:
## var strength:float = 1.0
## var strength_pow:float = 2.0
## return pow(strength,strength_pow)
@export_range(1.0,4.0,0.1,"or_greater") var strength_power:float = 2.0
## Decay changes the amount strength is decreased by, higher decay means the camera will come to a stop quicker. If you want the camera to shake indefintely use the "shake indefinitely" bool
@export_range(0.1,10.0,0.1,"or_less","or_greater") var decay:float = 0.5
## Changes if the shake will move the camera on the x axis
@export var shake_x:bool = true
## Changes if the shake will move the camera on the y axis
@export var shake_y:bool = true
## Makes it so the strength will never decay until stop shake is used
@export var shake_indefinitely:bool = false
var camera_line:ToolLine2D
var one_over_camera_zoom:Vector2
@export_custom(PROPERTY_HINT_NODE_TYPE,"Node2D",PROPERTY_USAGE_STORAGE) var target_parent:Node2D
var screen_position:Vector2
var half_viewport_x:float
var half_viewport_y:float
var packed_array:PackedVector2Array

func _draw() -> void:
	if _draw_viewport_rect:
		draw_viewport_rect()
	if target_function == G_Advanced_Cam.TARGET_FUNCTION.STAY_IN_AREA:
		draw_camera_bounds_rect()

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

	draw_line(dx,dy,self_modulate)
	draw_line(dxx,dyy,self_modulate)
	draw_line(dxx,dx,self_modulate)
	draw_line(dyy,dy,self_modulate)
	
	draw_string(NEXA_CUSTOM_FONT,Vector2(-75.0,(-(half_viewport_y*1.01)*one_over_camera_zoom.y)),"VIEWPORT SIZE")

## Draws the bounds area
func draw_camera_bounds_rect():
	if packed_array.is_empty():
		update_packed_bound_array()
	
	draw_line(packed_array[0],packed_array[1],_draw_color)
	draw_line(packed_array[2],packed_array[3],_draw_color)
	draw_line(packed_array[2],packed_array[0],_draw_color)
	draw_line(packed_array[3],packed_array[1],_draw_color)

## Creates bounds as a PackedVector2Array [0]NE [1]SE [2]NW [3]SW
func create_bounds()-> PackedVector2Array:
	var return_packed_array:PackedVector2Array = PackedVector2Array([Vector2(east_bound,-north_bound),Vector2(east_bound,south_bound),Vector2(-west_bound,-north_bound),Vector2(-west_bound,south_bound)])
	return return_packed_array

## Gets global bounds as a PackedVector2Array [0]NE [1]SE [2]NW [3]SW
func get_global_bounds() -> PackedVector2Array:
	var local_bounds:PackedVector2Array = create_bounds()
	var return_packed_array:PackedVector2Array
	for vector in local_bounds:
		var global_vec = Vector2(vector.x+global_position.x,vector.y+global_position.y)
		return_packed_array.append(global_vec)
	return return_packed_array

func get_closest_point_within_bounds(pos:Vector2) -> PackedVector2Array:
	var g_bounds:PackedVector2Array = get_global_bounds()
	var vec1:Vector2 = Vector2(0.0,0.0)
	var vec2:Vector2 = Vector2(0.0,0.0)
	if pos.x < g_bounds[2].x:
		vec1 = g_bounds[2]
		vec2 = g_bounds[3]
	elif pos.x > g_bounds[0].x:
		vec1 = g_bounds[0]
		vec2 = g_bounds[1]
	elif pos.y > g_bounds[1].y:
		vec1 = g_bounds[1]
		vec2 = g_bounds[3]
	elif pos.y < g_bounds[0].y:
		vec1 = g_bounds[2]
		vec2 = g_bounds[0]
	var intersect_point:PackedVector2Array = Geometry2D.get_closest_points_between_segments(vec1,vec2,pos,global_position)
	return intersect_point

## Creates the tool line 2d and adds it as a child (could also use a viewport draw instead)
func setup():
	camera_line = ToolLine2D.new()
	add_child(camera_line)
	camera_line.width = 2.0
	camera_line.global_position = Vector2(0,0)
	camera_line.add_point(global_position,0)
	camera_line.add_point(target_parent.global_position,1)
	for child in get_children():
		child.set("self_modulate",self_modulate)

func update_one_over_camera_zoom():
	one_over_camera_zoom = Vector2(1.0/camera_zoom_at_target.x,1.0/camera_zoom_at_target.y)

func update_packed_bound_array():
	packed_array = create_bounds()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		if camera_line:
			if camera_line.points.size() == 2:
				camera_line.global_position = Vector2(0,0)
				camera_line.set_point_position(0,global_position)
				camera_line.set_point_position(1,target_parent.global_position)
