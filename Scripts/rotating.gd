extends Activatable

@export var rotation_speed:float = 45.0
@export var flip_flop_roation:bool = false

var direction:DIRECTION = DIRECTION.CLOCKWISE
var flip_flop_timer:Timer = null

enum DIRECTION{
	CLOCKWISE,
	COUNTERCLOCKWISE,
}

func _ready() -> void:
	if flip_flop_roation:
		flip_flop_timer = Timer.new()
		add_child(flip_flop_timer)
		flip_flop_timer.autostart = false
		flip_flop_timer.wait_time = 0.1
		flip_flop_timer.one_shot = true
		flip_flop_timer.timeout.connect(timer_timeout)
	return

func execute_long(delta:float):
	flip_flop_timer.start()
	if !flip_flop_roation:
		rotate(deg_to_rad(1.0*rotation_speed*delta))
	else:
		match direction:
			DIRECTION.CLOCKWISE:
				rotate(deg_to_rad(1.0*rotation_speed*delta))
			DIRECTION.COUNTERCLOCKWISE:
				rotate(deg_to_rad(-1.0*rotation_speed*delta))
	return

func timer_timeout():
	match direction:
		DIRECTION.CLOCKWISE:
			direction = DIRECTION.COUNTERCLOCKWISE
		DIRECTION.COUNTERCLOCKWISE:
			direction = DIRECTION.CLOCKWISE
	return
