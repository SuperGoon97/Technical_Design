@tool
extends Node

signal camera_function_complete
signal move_camera_on

enum FOLLOW_TYPE{
	## Camera stays in the given locaiton
	STATIC,
	## Camera follows the target setting its location every physics frame
	SNAP,
	## Camera chases the target increasing in speed the further away it is
	LAG,
}

enum TARGET_FUNCTION{
	## Direcects camera to move to a position
	MOVE_TO,
	## Enforces bounds for the camera that it cannot leave
	STAY_IN_AREA,
	## Allows the camera to look at multiple things at once
	MULTI_TARGET,
	## Directs the camera to shake
	SHAKE,
}

enum MOVE_TO_TYPE{
	## Camera snaps to target
	SNAP,
	## Camera tweens to target
	TWEEN,
}
var advanced_camera:AdvancedCamera2D:
	set(value):
		advanced_camera = value
		advanced_camera.camera_zoom_change_complete.connect(_camera_zoom_complete)
	get:
		return advanced_camera

var temp_advanced_camera:AdvancedCamera2D
var camera_zoom_complete:bool = true

## Sets the camera follow type
func set_camera_follow_type(type:FOLLOW_TYPE):
	if advanced_camera:
		advanced_camera.set("camera_follow_type",type)

## Gets the camera follow type
func get_camera_follow_type():
	if advanced_camera:
		return advanced_camera.get("camera_follow_type")

## Sets the camera speed, only matters for Lag follow type
func set_camera_speed(speed:float):
	if advanced_camera:
		advanced_camera.set("camera_speed",speed)

## Gets the camera speed
func get_camera_speed():
	if advanced_camera:
		return advanced_camera.get("camera_speed")

## Sets the cameras main target
func set_camera_target(target:Node2D):
	if advanced_camera:
		advanced_camera.set("camera_target",target)

## Gets the cameras main target
func get_camera_target():
	if advanced_camera:
		return advanced_camera.get("camera_target")

## Gets the cameras screen transform
func get_camera_screen() -> Transform2D:
	if advanced_camera:
		return advanced_camera.get_screen_transform()
	else:
		return _get_temp_advanced_cam().get_screen_transform()

## Sets the camera_zoom
func set_camera_zoom(value:float):
	if advanced_camera:
		advanced_camera.set("zoom",value)

## Gets the cameras zoom
func get_camera_zoom():
	if advanced_camera:
		return advanced_camera.get("zoom")
	else:
		return _get_temp_advanced_cam().zoom

## Sets camera bound state, if value == true the camera will be bound to the area last set in set_camera_bounds
func set_camera_is_bound(value:bool):
	if advanced_camera:
		advanced_camera.set("lock_camera_to_camera_bounds",value)

## Gets camera bound state
func get_camera_is_bound() -> bool:
	if advanced_camera:
		return advanced_camera.lock_camera_to_camera_bounds
	else: return false

## Sets the cameras bounds
func set_camera_bounds(bounds:PackedVector2Array):
	if advanced_camera:
		advanced_camera.set("camera_bounds",bounds)

## Gets the camera bounds
func get_camera_bounds():
	if advanced_camera:
		return advanced_camera.camera_bounds
	else: return false

## Sets the camera multi target mode state. value == true will turn multi target on
func set_camera_multi_target_mode(value:bool):
	if advanced_camera:
		advanced_camera.set("camera_use_multi_target",value)

## Gets the camera multi target mode
func get_camera_multi_target_mode() -> bool:
	if advanced_camera:
		return advanced_camera.camera_use_multi_target
	else: return false

## Sets the camera multi targets
func set_camera_multi_targets(dict:Dictionary[Node2D,float]):
	if advanced_camera:
		advanced_camera.set("camera_multi_targets",dict)

## Adds camera multi targets. Note does not allow duplicates
func add_camera_multi_targets(dict:Dictionary[Node2D,float]):
	if advanced_camera:
		for key in dict:
			advanced_camera.call("add_camera_multi_target",key,dict[key])

## Gets the camera shake indefinitely state on the camera
func get_camera_shake_indefinitely() -> bool:
	if advanced_camera:
		return advanced_camera.camera_shake_indefinitely
	else: return false

## Sets the camera shake indefinitely state on the camera
func set_camera_shake_indefinitely(value:bool):
	if advanced_camera:
		advanced_camera.set("camera_shake_indefinitely",value)

## Tweens the camera to target
func tween_camera_to_target(target:Node2D,time_to_reach_target:float = 0.5,tween_easing:Tween.EaseType = Tween.EaseType.EASE_IN):
	if advanced_camera:
		set_camera_target(target)
		advanced_camera.call("tween_to_target",target,time_to_reach_target,tween_easing)

## Shakes the camera
func shake_camera(strength:float = 2.0,strength_pow:float = 2.0,decay_rate:float = 0.5,shake_x:bool = true ,shake_y:bool = true,camera_shake_indef:bool = false,add_strength = true):
	if advanced_camera:
		advanced_camera.call("add_camera_shake",strength,strength_pow,decay_rate,shake_x,shake_y,camera_shake_indef,add_strength)

## Sets the camera back to default settings and target. Also kills any active tweens
func set_camera_to_default():
	if advanced_camera:
		advanced_camera.call("camera_to_default")

## Forces the camera to a Vector2 position, camera will not stay there
func force_camera_to_vector(vec:Vector2):
	if advanced_camera:
		advanced_camera.call("force_to_vector",vec)

## Gets advanced cam for use in @tool scripts
func _get_temp_advanced_cam():
	return get_tree().get_first_node_in_group("AdvancedCamera2D")

## Camera target move to logic
func _move_to(target:AdvancedCameraTarget):
	print("move to")
	if target.move_by_change_target:
		set_camera_target(target)
	else:
		tween_camera_to_target(target,target.time_to_reach_target,target.tween_easing)
	await advanced_camera.camera_arrived_at_target
	target.camera_at_target.emit()
	if target.hold_camera_indefinitely:
		await move_camera_on
	if target.hold_camera_for > 0.0:
		await get_tree().create_timer(target.hold_camera_for).timeout
	if target.release_camera_back_to_default_after_hold:
		set_camera_to_default()
	return

## Camera target stay in area logic
func _stay_in_area(target:AdvancedCameraTarget):
	set_camera_bounds(target.get_global_bounds())
	set_camera_is_bound(true)
	if target.teleport_camera_to_nearest_point_in_bounds:
		var vec_array:PackedVector2Array = target.get_closest_point_within_bounds(get_camera_target().global_position)
		force_camera_to_vector(vec_array[0])
	return

## Camera target multi target logic
func _multi_target(target:AdvancedCameraTarget):
	set_camera_multi_target_mode(target.camera_use_multi_target)
	match target.multi_target_mode:
		target.MULTI_TARGET_MODE.ADD:
			add_camera_multi_targets(target.multi_targets)
		target.MULTI_TARGET_MODE.SET:
			set_camera_multi_targets(target.multi_targets)

## Camera target shake logic 
func _shake(target:AdvancedCameraTarget):
	if target.stop_shake:
		set_camera_shake_indefinitely(false)
		return
	match target.strength_mode:
		target.STRENGTH_MODE.ADD:
			shake_camera(target.strength,target.strength_power,target.decay,target.shake_x,target.shake_y,target.shake_indefinitely,true)
		target.STRENGTH_MODE.SET:
			shake_camera(target.strength,target.strength_power,target.decay,target.shake_x,target.shake_y,target.shake_indefinitely,false)

func _zoom(target:AdvancedCameraTarget):
	advanced_camera.change_camera_zoom(target.camera_zoom_at_target,target.do_tween_camera_zoom,target.camera_zoom_speed)

func execute_target_function(target:AdvancedCameraTarget):
	var move_type:TARGET_FUNCTION = target.target_function
	if target.camera_zoom_at_target != advanced_camera.zoom:
		camera_zoom_complete = false
		_zoom(target)
	match move_type:
		TARGET_FUNCTION.MOVE_TO:
			await _move_to(target)
		TARGET_FUNCTION.STAY_IN_AREA:
			_stay_in_area(target)
		TARGET_FUNCTION.MULTI_TARGET:
			_multi_target(target)
		TARGET_FUNCTION.SHAKE:
			_shake(target)
	while camera_zoom_complete == false:
		await get_tree().process_frame
	camera_function_complete.emit()

func _camera_zoom_complete():
	camera_zoom_complete = true
