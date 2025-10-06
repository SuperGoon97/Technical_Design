class_name AdvancedCamera2D extends Camera2D
## Base class for AdvancedCameras, inherits from camera2D


signal camera_arrived_at_target (target:Node2D)

@export_category("CameraDefaults")
## Cameras default target, may throw errors if "null"
@export var camera_default_target:Node2D
## Starting camera follow mode. Possible modes are STATIC,SNAP,LAG
@export var camera_default_follow_type:G_Advanced_Cam.FOLLOW_TYPE
## Default speed the camera will travel
@export_range(0.0,1000.0,1.0,"or_greater") var camera_default_speed:float = 100.0
## Default "elasticity" of the camera in lag mode
@export_range(1.0,100.0,1.0,"or_greater") var camera_default_lag_elastic:float = 10.0

var current_tween:Tween
var camera_moving_to:bool = false

@onready var camera_target:Node2D = camera_default_target
@onready var camera_follow_type:G_Advanced_Cam.FOLLOW_TYPE = camera_default_follow_type
@onready var camera_speed:float = camera_default_speed
@onready var camera_lag_elastic:float = camera_default_lag_elastic

func _ready() -> void:
	ready_checks()

func _physics_process(delta: float) -> void:
	follow_target(delta)

## Match statement to decide which follow type is in use
func follow_target(delta: float):
	if camera_moving_to == false:
		match camera_follow_type:
			G_Advanced_Cam.FOLLOW_TYPE.STATIC:
				pass
			G_Advanced_Cam.FOLLOW_TYPE.SNAP:
				snap_to_target()
			G_Advanced_Cam.FOLLOW_TYPE.LAG:
				lag_to_target(delta,camera_speed)

## Snaps camera to camera target
func snap_to_target(do_tween_to_target:bool = false, target_override:Node2D = camera_target,time_to_reach_target:float = 0.5):
	if do_tween_to_target:
		tween_to_target(target_override,time_to_reach_target)
	else:
		global_position = camera_target.global_position

## Camera moves towards camera target
func lag_to_target(delta:float ,speed_modifier:float = 100.0):
	var direction:Vector2 = Vector2(camera_target.global_position - global_position).normalized()
	var distance:float = global_position.distance_to(camera_target.global_position)
	var rubber_banding:float = distance/camera_lag_elastic
	global_position += (direction * speed_modifier * rubber_banding) * delta

## Tweens the camera to target node, if no target provided to method defaults to camera default target
func tween_to_target(target:Node2D = camera_default_target,time_to_reach_target:float = 0.5): 
	kill_tween()
	camera_moving_to = true
	current_tween = get_tree().create_tween()
	var tween_target:Node2D = target
	if !target:
		tween_target = camera_target
	current_tween.tween_property(self,"global_position",tween_target.global_position,time_to_reach_target)
	await current_tween.finished
	camera_arrived_at_target.emit(target)

## Kills the any active tween
func kill_tween():
	if current_tween:
		if current_tween.is_running():
			current_tween.kill()

## Resets camera focusing back on the default target
func release_cam():
	camera_target = camera_default_target
	camera_speed = camera_default_speed
	camera_follow_type = camera_default_follow_type
	camera_lag_elastic = camera_default_lag_elastic
	kill_tween()
	camera_moving_to = false
	

## Sets camera defaults to the current camera settings
func set_camera_defaults_to_current():
	camera_default_target = camera_target
	camera_default_speed = camera_speed
	camera_default_follow_type = camera_follow_type
	camera_default_lag_elastic = camera_lag_elastic
	
## Runs all "check" functions
func ready_checks():
	check_valid_target()
	check_multiple_cameras()
	set_g_advanced_cam_var()

func set_g_advanced_cam_var():
	G_Advanced_Cam.set("advanced_camera",self)

## Checks the cameras target is valid
func check_valid_target():
	if !camera_default_target:
		print("No default Node2D set for AdvancedCamera2D")

## Checks if multiple cameras are present in the scene
func check_multiple_cameras():
	if get_tree().get_nodes_in_group("AdvancedCamera2D").size() > 1:
		print("Multiple AdvancedCamera2D's in scene !")
