class_name AdvancedCamera2D extends Camera2D
## Base class for AdvancedCameras, inherits from camera2D


signal camera_arrived_at_target(target:Node2D)
signal camera_zoom_change_complete()
signal camera_shake_complete()

@export_category("CameraDefaults")
## Cameras default target, may throw errors if "null"
@export var camera_default_target:Node2D
## Starting camera follow mode. Possible modes are STATIC,SNAP,LAG
@export var camera_default_follow_type:G_Advanced_Cam.FOLLOW_TYPE
## Camera default zoom
@export_custom(PROPERTY_HINT_LINK,"") var camera_default_zoom:Vector2 = Vector2(1.0,1.0):
	set(value):
		zoom = value
		camera_default_zoom = value
## Default speed the camera will travel
@export_range(0.0,1000.0,1.0,"or_greater") var camera_default_speed:float = 50.0
## Default "elasticity" of the camera in lag mode
@export_range(1.0,100.0,1.0,"or_greater") var camera_default_lag_elastic:float = 10.0

var current_tween:Tween
var camera_moving_to:bool = false
var camera_target_changed:bool = false
var camera_distance_tolerance:float = 10.0
var camera_use_multi_target:bool = false:
	get:
		return camera_use_multi_target
	set(value):
		camera_use_multi_target = value
# Camera shakevariables
## Amplitude is base multiplier for camera offset during shake
var camera_shake_amplitude:float = 40.0:
	get:
		return camera_shake_amplitude
	set(value):
		camera_shake_amplitude = value
## Camera shake strength, this value affects the offset strength alot so keep it small
var camera_shake_strength:float = 0.0
## Power value for camera shake strength
var camera_shake_strength_pow:float = 2.0
## Rate that camera shake is reduced
var camera_shake_decay:float = 0.5:
	get:
		return camera_shake_decay
	set(value):
		camera_shake_decay = value
## How jittery the camera shake is
var camera_shake_noise_speed:float = 5.0
var camera_shake_noise_y:float = 0.0
var camera_shake_x:bool = true
var camera_shake_y:bool = true
var camera_shake_warm_up:float = 0.0
var camera_warm_up_rate:float = 10.0
var camera_shake_indefinitely:bool = false
## Lock to camera to camera bounds
var lock_camera_to_camera_bounds:bool = false
## Camera bounds stored as PackedVector2Array [0]NE [1]SE [2]NW [3]SW
var camera_bounds:PackedVector2Array:
	get:
		return camera_bounds
	set(value):
		camera_bounds = value

@onready var camera_target:Node2D = camera_default_target:
	get:
		return camera_target
	set(value):
		if camera_target != value:
			camera_target_changed = true
		camera_target = value
@onready var camera_multi_targets:Dictionary[Node2D,float] = {camera_target:1.0}
@onready var camera_follow_type:G_Advanced_Cam.FOLLOW_TYPE = camera_default_follow_type
@onready var camera_speed:float = camera_default_speed
@onready var camera_lag_elastic:float = camera_default_lag_elastic
@onready var camera_perlin_noise:FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
	ready_checks()

func _physics_process(delta: float) -> void:
	follow_target(delta)
	if camera_shake_strength > 0.0:
		camera_shake_warm_up = min(camera_shake_warm_up + camera_warm_up_rate * delta ,1.0)
		if !camera_shake_indefinitely:
			camera_shake_strength = max(camera_shake_strength - camera_shake_decay * delta,0.0)
		camera_shake_noise_y += camera_shake_noise_speed * (1.0 / (camera_shake_strength+ 0.1))
		camera_shake()
		if camera_shake_strength == 0.0:
			camera_shake_complete.emit()
			camera_shake_warm_up = 0.0

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
	var direction:Vector2 = calculate_direction()
	var distance:float = calculate_distance()
	var rubber_banding:float = distance/camera_lag_elastic
	if lock_camera_to_camera_bounds:
		if check_position_within_bounds(global_position +((direction * speed_modifier * rubber_banding) * delta)):
			global_position += (direction * speed_modifier * rubber_banding) * delta
		elif check_position_within_x_bounds(Vector2(global_position.x +((direction.x * speed_modifier * rubber_banding) * delta),global_position.y)):
			global_position.x += (direction.x * speed_modifier * rubber_banding) * delta
		elif check_position_within_y_bounds(Vector2(global_position.x,global_position.y+((direction.y * speed_modifier * rubber_banding) * delta))):
			global_position.y += (direction.y * speed_modifier * rubber_banding) * delta
	else:
		global_position += (direction * speed_modifier * rubber_banding) * delta
	if camera_target_changed:
		if global_position.distance_to(camera_target.global_position) < camera_distance_tolerance:
			camera_arrived_at_target.emit(camera_target)
			camera_target_changed = false

## Tweens the camera to target node, if no target provided to method defaults to camera default target
func tween_to_target(target:Node2D = camera_default_target,time_to_reach_target:float = 0.5,tween_easing_type:Tween.EaseType = Tween.EaseType.EASE_IN): 
	kill_tween()
	camera_moving_to = true
	current_tween = get_tree().create_tween()
	var tween_target:Node2D = target
	if !target:
		tween_target = camera_target
	current_tween.set_ease(tween_easing_type)
	current_tween.tween_property(self,"global_position",tween_target.global_position,time_to_reach_target)
	await current_tween.finished
	camera_arrived_at_target.emit(target)

# NOT IMPLEMENTED - Maybe implemented in future
#func move_camera_until_at_target(target:Node2D,camera_max_speed:float,camera_acceleration_speed:float,allow_overshoot:bool,camera_distance_tolerance:float = 1.0):
	#camera_moving_to = true
	#var camera_at_target:bool
	#var decelerate = false
	#var target_direction = Vector2(camera_target.global_position - global_position).normalized()
	#var direction:Vector2 = target_direction
	#var distance:float
	#var last_distance:float
	#var current_speed:float = 0.1
	#var smooth:float
	#
	#if camera_acceleration_speed <= 0.0: current_speed = camera_max_speed
	#while(!camera_at_target):
		#smooth = (current_speed/camera_max_speed)+0.5
		#
		#last_distance = distance
		#distance = global_position.distance_to(camera_target.global_position)
		#
		# acceleration / deceleration
		#if !decelerate:
			#if current_speed < camera_max_speed:
				#if current_speed + camera_acceleration_speed >= camera_max_speed: current_speed = camera_max_speed
				#else: current_speed += camera_acceleration_speed * smooth
		#else:
			#if current_speed > camera_max_speed/10.0:
				#current_speed -= camera_acceleration_speed * 2.0 * smooth
			#else: decelerate = false
		#
		#if distance <= camera_distance_tolerance and !allow_overshoot:
			#camera_at_target = true
		#elif distance <= camera_distance_tolerance and current_speed < camera_max_speed/4.0:
			#camera_at_target = true
		#if last_distance:
			#if distance > last_distance and !decelerate:
				#decelerate = true
		#if !direction.is_equal_approx(target_direction):
			#direction = direction.rotated(45.0*get_process_delta_time())
			#if rad_to_deg(direction.angle_to_point(target_direction)) < 5.0:
				#direction = target_direction
		#
		#target_direction = Vector2(camera_target.global_position - global_position).normalized()
		#global_position += (direction * current_speed * 15.0) * get_physics_process_delta_time()
		#await get_tree().physics_frame
	#force_to_target(target)

## Forces camera to target Node2D
func force_to_target(target:Node2D = camera_target):
	global_position = target.global_position
	camera_arrived_at_target.emit(target)

## Forces camera to target Vector2D
func force_to_vector(vec:Vector2):
	if vec:
		global_position = vec

## Kills any active tween
func kill_tween():
	if current_tween:
		if current_tween.is_running():
			current_tween.kill()

## Resets camera focusing back on the default target
func camera_to_default():
	camera_target = camera_default_target
	camera_speed = camera_default_speed
	camera_follow_type = camera_default_follow_type
	camera_lag_elastic = camera_default_lag_elastic
	kill_tween()
	camera_moving_to = false

func calculate_direction():
	var ret_direction:Vector2
	if !camera_use_multi_target:
		ret_direction = Vector2(camera_target.global_position - global_position).normalized()
	elif camera_use_multi_target:
		ret_direction = Vector2(calculate_multi_target_point() - global_position).normalized()
	return ret_direction

func calculate_distance() -> float:
	var ret_distance:float
	if !camera_use_multi_target:
		ret_distance = global_position.distance_to(camera_target.global_position)
	elif camera_use_multi_target:
		ret_distance = global_position.distance_to(calculate_multi_target_point())
	return ret_distance

## Simple summ function
func sum(accum:float, number:float) -> float:
	return accum+number

## calculates the weighted barycentre of the targets in camera_multi_targets
func calculate_multi_target_point() -> Vector2:
	#print(camera_multi_targets)
	var sum_vec:Vector2 = Vector2(0.0,0.0)
	var ret_vec:Vector2
	var sum_weight:float = camera_multi_targets.values().reduce(sum,0.0)
	for key in camera_multi_targets:
		sum_vec = Vector2(sum_vec.x + (key.global_position.x * camera_multi_targets[key]),sum_vec.y + (key.global_position.y * camera_multi_targets[key]))
	
	ret_vec = Vector2(sum_vec.x/sum_weight,sum_vec.y/sum_weight)
	return ret_vec
	
## Adds a new target to camera multi target, default weight is 1.0
func add_camera_multi_target(target:Node2D,weight:float = 1.0):
	print("add")
	camera_multi_targets[target] = weight

func remove_camera_multi_target(target:Node2D):
	if camera_multi_targets.has(target):
		camera_multi_targets.erase(target)

func add_camera_shake(strength:float = 2.0,strength_pow:float = 2.0,decay_rate:float = 0.5,shake_x:bool = true ,shake_y:bool = true,camera_shake_indef:bool = false,add_strength:bool = true):
	if add_strength:
		camera_shake_strength += strength
	else:
		camera_shake_strength = strength
	camera_shake_strength_pow = strength_pow
	camera_shake_decay = decay_rate
	camera_shake_x = shake_x
	camera_shake_y = shake_y
	camera_shake_indefinitely = camera_shake_indef

func change_camera_zoom(new_zoom:Vector2,do_tween:bool = false,time_to_reach_zoom:float = 0.5):
	if !do_tween:
		zoom = new_zoom
		return
	var zoom_tween:Tween = create_tween()
	zoom_tween.tween_property(self,"zoom",new_zoom,time_to_reach_zoom)
	await zoom_tween.finished
	camera_zoom_change_complete.emit()

func camera_shake():
	var strength = pow(camera_shake_strength,camera_shake_strength_pow)
	if camera_shake_x:
		offset.x = (camera_shake_amplitude * strength * sample_camera_noise(Vector2(camera_perlin_noise.seed,camera_shake_noise_y))* camera_shake_warm_up)
	if camera_shake_y:
		offset.y = (camera_shake_amplitude * strength * sample_camera_noise(Vector2(camera_perlin_noise.seed*2.0,camera_shake_noise_y))* camera_shake_warm_up)
	
## Checks if the position is within the cameras y bound
func check_position_within_y_bounds(pos:Vector2) -> bool:
	if pos.y > camera_bounds[0].y:
		if pos.y < camera_bounds[1].y:
			return true
	return false

## Checks if the position is within the cameras x bound
func check_position_within_x_bounds(pos:Vector2) -> bool:
	if pos.x < camera_bounds[1].x:
		if pos.x > camera_bounds[2].x:
			return true
	return false

## Checks if the position is withing the cameras bounds
func check_position_within_bounds(pos:Vector2) -> bool:
	if check_position_within_x_bounds(pos):
		if check_position_within_y_bounds(pos):
			return true
	return false

## Sets camera defaults to the current camera settings
func set_camera_defaults_to_current():
	camera_default_target = camera_target
	camera_default_speed = camera_speed
	camera_default_follow_type = camera_follow_type
	camera_default_lag_elastic = camera_lag_elastic
	camera_default_zoom = zoom
	
## Runs all "check" functions
func ready_checks():
	check_valid_target()
	check_multiple_cameras()
	set_g_advanced_cam_var()
	setup_camera_noise()

func setup_camera_noise():
	camera_perlin_noise.set("noise_type",3)
	camera_perlin_noise.set("seed",randi() % 1000 + 1)

func sample_camera_noise(sample_position:Vector2) -> float:
	return camera_perlin_noise.get_noise_2d(sample_position.x,sample_position.y)

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
