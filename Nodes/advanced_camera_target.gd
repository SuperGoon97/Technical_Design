@tool
class_name AdvancedCameraTarget extends Node2D

var camera_line:Line2D
var target_parent:Node2D

func _ready() -> void:
	call_deferred("setup")

func setup():
	camera_line = Line2D.new()
	add_child(camera_line)
	camera_line.global_position = Vector2(0,0)
	camera_line.add_point(global_position,0)
	camera_line.add_point(target_parent.position,1)

func _process(_delta: float) -> void:
	if camera_line.points.size() == 2:
		camera_line.global_position = Vector2(0,0)
		camera_line.set_point_position(0,global_position)
		camera_line.set_point_position(1,target_parent.position)
