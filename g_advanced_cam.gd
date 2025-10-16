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
	STAY_IN_AREA
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

func execute_target_function(target:AdvancedCameraTarget):
	var move_type:TARGET_FUNCTION = target.target_function
	match move_type:
		TARGET_FUNCTION.MOVE_TO:
			if target.camera_max_speed > 0:
				move_camera_toward(target,target.camera_max_speed,target.camera_acceleration_speed,target.allow_overshoot)
			else:
				move_camera_to_target(target,target.time_to_reach_target,target.tween_easing)
			await advanced_camera.camera_arrived_at_target
			target.camera_at_target.emit()
			if target.hold_camera_indefinitely:
				await move_camera_on
			if target.hold_camera_for > 0.0:
				await get_tree().create_timer(target.hold_camera_for).timeout
			camera_function_complete.emit()
			return
	pass

func move_camera_to_target(target:Node2D,time_to_reach_target:float = 0.5,tween_easing:Tween.EaseType = Tween.EaseType.EASE_IN):
	if advanced_camera:
		set_camera_target(target)
		advanced_camera.call("tween_to_target",target,time_to_reach_target,tween_easing)
	pass

func move_camera_toward(target:Node2D,camera_max_speed:float,camera_acceleration_speed:float,allow_overshoot:bool):
	if advanced_camera:
		set_camera_target(target)
		advanced_camera.call("move_camera_until_at_target",target,camera_max_speed,camera_acceleration_speed,allow_overshoot)
	pass

func release_camera():
	if advanced_camera:
		advanced_camera.call("release_cam")

func get_temp_advanced_cam():
	return get_tree().get_first_node_in_group("AdvancedCamera2D")
