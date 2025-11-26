extends Activatable

@export var maximum_position:Vector2
@export var speed:float = 1.0
@export var reset_speed:float = 1.0
@export var hold_for_time:float = 0.1
@onready var starting_point:Vector2 = position
@onready var destination_point:Vector2 = starting_point + maximum_position

var timer:Timer
var alpha = 0.0
enum DIRECTION{
	forawrd,
	backward,
}
var direction:DIRECTION = DIRECTION.forawrd

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.autostart = false
	timer.one_shot = true
	timer.wait_time = hold_for_time
	timer.timeout.connect(set_direction_backward)

func _physics_process(delta: float) -> void:
	if direction == DIRECTION.backward:
		alpha -= reset_speed * delta
	alpha = clamp(alpha,0.0,1.0)
	position = lerp(starting_point,destination_point,alpha)

func execute_long(delta:float):
	timer.start()
	direction = DIRECTION.forawrd
	alpha += speed * delta

func set_direction_backward():
	direction = DIRECTION.backward
