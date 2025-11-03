@tool
class_name AdvancedCameraTarget extends Node2D

## Emitted when the camera has arrived this target
@warning_ignore("unused_signal")
signal all_actions_complete
signal camera_at_target
signal draw_camera_icon_changed(state:bool)
const NEXA_CUSTOM_FONT = preload("res://Resources/Fonts/nexa_custom_font.tres")

@export_storage var camera_action_ui:Dictionary[CameraAction,ACSprite2D]

@export var camera_actions:Array[CameraAction]:
	set(value):
		camera_action_ui.clear()
		camera_actions = value
		call_deferred("setup_camera_actions")

@export_tool_button("Force Update","Callable") var force_update = update_one_over_camera_zoom
@export var target_function:G_Advanced_Cam.CAMERA_ACTION = G_Advanced_Cam.CAMERA_ACTION.MOVE_TO:
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
## Changes if the camera will tween to the desired zoom or snap to the desired zoom
@export var do_tween_camera_zoom:bool = false
## The speed that the camera will tween to desired zoom if do_tween_camera_zoom is true
@export var camera_zoom_speed:float = 0.5

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
	if target_function == G_Advanced_Cam.CAMERA_ACTION.STAY_IN_AREA:
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

func setup_camera_actions():
	for action in camera_actions:
		if action == null: continue
		var new_acsprite2d:ACSprite2D = ACSprite2D.new()
		add_child(new_acsprite2d)
		new_acsprite2d.name = action.get_script().get_global_name()
		new_acsprite2d.set_owner(get_tree().edited_scene_root)
		action.request_icon.connect(new_acsprite2d.set_icon)
		action.request_icon_visibility_change.connect(new_acsprite2d.set_visibilty)
		action.request_color_change.connect(new_acsprite2d.set_color)
		
		camera_action_ui[action] = new_acsprite2d
		
		print("creation = " + str(camera_action_ui))
		action.setup()
	
	var t_children = get_children()
	var ui_values = camera_action_ui.values()
	for t in t_children:
		if t is ACSprite2D:
			if !ui_values.has(t):
				clear_camera_actiun_ui(t)

func clear_camera_actiun_ui(acsprite:ACSprite2D):
	await get_tree().create_timer(1.0).timeout
	acsprite.queue_free()

func execute_actions():
	for action in camera_actions:
		if action.pre_wait > 0.0:
			await get_tree().create_timer(action.pre_wait).timeout
		match action.action_function:
			G_Advanced_Cam.CAMERA_ACTION.MOVE_TO:
				G_Advanced_Cam._move_to(self,action)
			G_Advanced_Cam.CAMERA_ACTION.SHAKE:
				G_Advanced_Cam._shake(action)
			G_Advanced_Cam.CAMERA_ACTION.RELEASE:
				G_Advanced_Cam.set_camera_to_default()
			G_Advanced_Cam.CAMERA_ACTION.MULTI_TARGET:
				G_Advanced_Cam._multi_target(self,action)
		if action.hold_camera_until_move_camera_on_emitted:
			await G_Advanced_Cam.move_camera_on
		if action.post_wait > 0.0:
			await get_tree().create_timer(action.post_wait).timeout
	all_actions_complete.emit()

func add_move_to_to_queue(action:CameraActionMoveTo):
	G_Advanced_Cam._move_to(self,action)
	await camera_at_target
	if action.hold_camera_until_move_camera_on_emitted:
		await G_Advanced_Cam.move_camera_on

func update_action_icon(cam_action:CameraAction,_icon:CompressedTexture2D):
	camera_action_ui[cam_action].icon = _icon

func update_action_icon_visibility(cam_action:CameraAction,state:bool):
	camera_action_ui[cam_action].do_draw_icon = state

func update_action_color(cam_action:CameraAction,_color:Color):
	camera_action_ui[cam_action].draw_color = _color

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
