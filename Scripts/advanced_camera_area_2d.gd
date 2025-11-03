@tool
class_name AdvancedCameraArea2D extends Area2D


const ADVANCED_CAMERA_TARGET = preload("uid://qqys3tfvvyt7")

@export_tool_button("Create Area Target","Callable") var create_target_action = create_target
@export_tool_button("Remove Last Area Target","Callable") var remove_last_target_action = remove_last_target

@export var is_one_shot:bool = false

@export_category("AreaDefaults")
@export var is_player_area:bool = false
@export var area_color:Color = Color(0.0, 0.6, 0.702, 0.42):
	set(value):
		area_color = value
		update_area_color()
	get:
		return area_color

@export var area_targets:Array[AdvancedCameraTarget]
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var has_activated = false

func _ready() -> void:
	update_area_color()
	setup_build_lines()

func create_target():
	var new_target:AdvancedCameraTarget = ADVANCED_CAMERA_TARGET.instantiate()
	add_child(new_target)
	new_target.name = "AdvancedCameraTarget %s" % area_targets.size()
	if area_targets.size() > 0:
		new_target.target_parent = area_targets.back()
	else:
		new_target.target_parent = self
		
	new_target.set_owner(get_tree().edited_scene_root)
	new_target.set("self_modulate",Color(area_color.r,area_color.g,area_color.b))
	area_targets.push_back(new_target)
	setup_build_lines()

func remove_last_target():
	var last_area_target = area_targets.pop_back()
	if last_area_target:
		last_area_target.queue_free()

func update_area_color():
	if collision_shape_2d:
		collision_shape_2d.debug_color = area_color

func setup_build_lines():
	for target in area_targets:
		target.setup()

func _on_area_entered(area: Area2D) -> void:
	if has_activated == false:
		var advanced_camera_area_2d := area as AdvancedCameraArea2D
		if advanced_camera_area_2d and area.is_player_area:
			if area_targets.size() > 0:
				execute_camera_area_targets()
		if is_one_shot:
			has_activated = true

func execute_camera_area_targets():
	for target in area_targets:
		target.execute_actions()
		await target.all_actions_complete
