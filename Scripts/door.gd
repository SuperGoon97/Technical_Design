extends Activatable

@export var y_distance_to_move:float = 125.0
@export var speed:float = 0.5
@export var locked:bool = false
@onready var default_position:Vector2 = global_position
@onready var lock: Sprite2D = $Lock

var door_tween:Tween

func _ready() -> void:
	if locked:
		lock.visible = true

var door_open:bool = false:
	set(value):
		if value == true:
			open_door()
		else:
			close_door()
		door_open = value

func execute():
	if locked:
		await get_tree().create_timer(0.25).timeout
		lock.visible = false
		locked = false
		await get_tree().create_timer(0.25).timeout
	door_open = !door_open

func open_door():
	do_tween(-y_distance_to_move)

func do_tween(input:float):
	if door_tween:
		if door_tween.is_running():
			door_tween.kill()
	door_tween = create_tween()
	door_tween.tween_property(self,"global_position",Vector2(default_position.x,default_position.y + input),speed)

func close_door():
	do_tween(0.0)
