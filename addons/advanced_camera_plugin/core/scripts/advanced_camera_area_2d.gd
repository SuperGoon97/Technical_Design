@tool
class_name AdvancedCameraArea2D extends Area2D

signal player_exited_area

@export_tool_button("Create Area Target","Callable") var create_target_action = create_target
@export_tool_button("Remove Last Area Target","Callable") var remove_last_target_action = remove_last_target

@export var is_one_shot:bool = false

@export_category("AreaDefaults")
@export var other_area_active_state:Dictionary[AdvancedCameraArea2D,bool]:
	set(value):
		if value.has(self):
			value.erase(self)
		other_area_active_state = value
@export var is_player_area:bool = false
@export var is_active_on_start:bool = true:
	set(value):
		is_active_on_start = value
		set_is_active(value)
@export var deactivate_after_overlap:bool = true
@export var area_color:Color = Color(0.0, 0.6, 0.702, 0.42):
	set(value):
		area_color = value
		update_area_color()
	get:
		return area_color

@export var area_targets:Array[AdvancedCameraTarget]
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var has_activated = false
var activation_time:float = 1.0
func _ready() -> void:
	update_area_color()
	setup_build_lines()

func create_target():
	var new_target:AdvancedCameraTarget = AdvancedCameraTarget.new()
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
	if is_player_area: return
	if has_activated == false:
		var advanced_camera_area_2d := area as AdvancedCameraArea2D
		if advanced_camera_area_2d and area.is_player_area:
			print("player entered area " + name)
			if area_targets.size() > 0:
				await execute_camera_area_targets()
				set_other_tarets_active()
		if is_one_shot:
			has_activated = true
		if deactivate_after_overlap:
			set_is_active(false)

func _on_area_exited(area: Area2D) -> void:
	if area is AdvancedCameraArea2D:
		if area.is_player_area:
			await player_exited_area

func execute_camera_area_targets():
	for target in area_targets:
		target.execute_actions()
		await target.all_actions_complete

func set_is_active(state:bool):
	if state == true:
		if !Engine.is_editor_hint():
			if is_node_ready():
				await get_tree().create_timer(activation_time).timeout
				print(name + " has been activated")
				set_deferred("monitoring",state)
				set_deferred("monitorable",state)
	else:
		set_deferred("monitoring",state)
		set_deferred("monitorable",state)

func set_other_tarets_active():
	print("set other targets called")
	for area in other_area_active_state:
		area.set_is_active(other_area_active_state[area])
