class_name MovingPlatforms extends Node2D

const ONE_WAY_PLATFORM = preload("res://Scenes/Platforms/one_way_platform.tscn")

@export var number_of_platforms:int = 0
@export var platform_speed:float = 1.0

@onready var point_marker_1: Sprite2D = $PointMarker1
@onready var point_marker_2: Sprite2D = $PointMarker2

var platform_array:Array[OneWayPlatform]

func _ready() -> void:
	create_platforms()
	point_marker_1.hide()
	point_marker_2.hide()

func create_platforms():
	for n in number_of_platforms:
		var new_platform:OneWayPlatform = ONE_WAY_PLATFORM.instantiate()
		add_child(new_platform)
		platform_array.push_back(new_platform)
		new_platform.platform_speed = platform_speed
		if n%2 == 0:
			new_platform.send_to_background()
		new_platform.position = (point_marker_2.position + get_position_between_markers(n))
		new_platform.platform_targets = [point_marker_1,point_marker_2]

func get_position_between_markers(itterator:int) -> Vector2:
	var ret_pos:Vector2
	var a:float  = (itterator + 1.0)/number_of_platforms
	print(a)
	ret_pos = lerp(point_marker_2.position,point_marker_1.position,a)
	return ret_pos
