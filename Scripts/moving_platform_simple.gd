class_name MovingPlatformSimple extends Activatable

signal vector_to_add_changed

@export var vector_to_add_to_position:Vector2:
	set(value):
		vector_to_add_to_position = value
		vector_to_add_changed.emit()

@export var speed:float = 0.5
@onready var defualt_position:Vector2 = global_position

var tween:Tween

var state:bool = false:
	set(value):
		state_check(value)
		state = value

func execute():
	state = !state

func state_check(input:bool):
	if input == true:
		do_tween(vector_to_add_to_position)
	else:
		do_tween(Vector2(0.0,0.0))

func do_tween(input:Vector2):
	if tween:
		if tween.is_running():
			tween.kill()
	tween = create_tween()
	tween.tween_property(self,"global_position",defualt_position + input,speed)
