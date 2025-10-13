extends Node

enum FOLLOW_TYPE{
	## Camera stays in the given locaiton
	STATIC,
	## Camera follows the target setting its location every physics frame
	SNAP,
	## Camera chases the target increasing in speed the further away it is
	LAG,
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
		advanced_camera.get("camera_target")

func move_camera_to_target(target:Node2D,time_to_reach_target:float = 0.5,_move_type:MOVE_TO_TYPE = MOVE_TO_TYPE.SNAP):
	if advanced_camera:
		set_camera_target(target)
		advanced_camera.call("tween_to_target",target,time_to_reach_target)
	pass

func release_camera():
	if advanced_camera:
		advanced_camera.call("release_cam")
