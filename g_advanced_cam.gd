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
	MOVE_TO,
	STAY_IN_AREA,
	MULTI_TARGET,
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
	get:
		return advanced_camera

var temp_advanced_camera:AdvancedCamera2D

func set_camera_follow_type(type:FOLLOW_TYPE):
	if advanced_camera:
		advanced_camera.set("camera_follow_type",type)

func get_camera_follow_type():
	if advanced_camera:
		return advanced_camera.get("camera_follow_type")

func set_camera_speed(speed:float):
	if advanced_camera:
		advanced_camera.set("camera_speed",speed)

func get_camera_speed():
	if advanced_camera:
		return advanced_camera.get("camera_speed")

func set_camera_target(target:Node2D):
	if advanced_camera:
		advanced_camera.set("camera_target",target)

func get_camera_target():
	if advanced_camera:
		return advanced_camera.get("camera_target")

func get_camera_screen() -> Transform2D:
	if advanced_camera:
		return advanced_camera.get_screen_transform()
	else:
		return get_temp_advanced_cam().get_screen_transform()

func get_camera_zoom():
	if advanced_camera:
		return advanced_camera.get("zoom")
	else:
		return get_temp_advanced_cam().zoom

func get_camera_is_bound() -> bool:
	if advanced_camera:
		return advanced_camera.lock_camera_to_camera_bounds
	else: return false

func set_camera_is_bound(value:bool):
	if advanced_camera:
		advanced_camera.set("lock_camera_to_camera_bounds",value)

func set_camera_bounds(bounds:PackedVector2Array):
	if advanced_camera:
		advanced_camera.set("camera_bounds",bounds)

func get_camera_multi_target_mode() -> bool:
	if advanced_camera:
		return advanced_camera.camera_use_multi_target
	else: return false

func set_camera_multi_target_mode(value:bool):
	if advanced_camera:
		advanced_camera.set("camera_use_multi_target",value)

func execute_target_function(target:AdvancedCameraTarget):
	var move_type:TARGET_FUNCTION = target.target_function
	match move_type:
		TARGET_FUNCTION.MOVE_TO:
			if target.move_by_change_target:
				move_camera_to_target_with_notify(target)
			else:
				move_camera_to_target(target,target.time_to_reach_target,target.tween_easing)
			await advanced_camera.camera_arrived_at_target
			target.camera_at_target.emit()
			if target.hold_camera_indefinitely:
				await move_camera_on
			if target.hold_camera_for > 0.0:
				await get_tree().create_timer(target.hold_camera_for).timeout
			if target.release_camera_back_to_default_after_hold:
				release_camera()
			camera_function_complete.emit()
			return
		TARGET_FUNCTION.STAY_IN_AREA:
			set_camera_bounds(target.get_global_bounds())
			set_camera_is_bound(true)
			if target.teleport_camera_to_nearest_point_in_bounds:
				var vec_array:PackedVector2Array = target.get_closest_point_within_bounds(get_camera_target().global_position)
				force_camera_to_vector(vec_array[0])
			return
		TARGET_FUNCTION.MULTI_TARGET:
			set_camera_multi_target_mode(target.camera_use_multi_target)
			match target.multi_target_mode:
				target.MULTI_TARGET_MODE.ADD:
					add_camera_multi_targets(target.multi_targets)
				target.MULTI_TARGET_MODE.SET:
					set_camera_multi_targets(target.multi_targets)

func set_camera_multi_targets(dict:Dictionary[Node2D,float]):
	if advanced_camera:
		advanced_camera.set("camera_multi_targets",dict)

func add_camera_multi_targets(dict:Dictionary[Node2D,float]):
	if advanced_camera:
		for key in dict:
			advanced_camera.call("add_camera_multi_target",key,dict[key])

func move_camera_to_target_with_notify(target:Node2D):
	set_camera_target(target)

func move_camera_to_target(target:Node2D,time_to_reach_target:float = 0.5,tween_easing:Tween.EaseType = Tween.EaseType.EASE_IN):
	if advanced_camera:
		set_camera_target(target)
		advanced_camera.call("tween_to_target",target,time_to_reach_target,tween_easing)
	pass

func release_camera():
	if advanced_camera:
		advanced_camera.call("release_cam")

func force_camera_to_vector(vec:Vector2):
	if advanced_camera:
		advanced_camera.call("force_to_vector",vec)

func get_temp_advanced_cam():
	return get_tree().get_first_node_in_group("AdvancedCamera2D")
