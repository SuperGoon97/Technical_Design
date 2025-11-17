extends Activatable

@onready var animatable_body_2d: AnimatableBody2D = $AnimatableBody2D

@export var maximum_position:Vector2
@export var speed:float = 1.0
@export var randomise_start_point:bool = false
@onready var starting_point:Vector2 = position
@onready var destination_point:Vector2 = starting_point + maximum_position

var alpha = 0.0
enum DIRECTION{
	forawrd,
	backward,
}
var direction:DIRECTION = DIRECTION.forawrd

func _ready() -> void:
	if randomise_start_point:
		randomise_starting_point()

func randomise_starting_point():
	alpha = randf_range(0.05,0.95)
	position = lerp(starting_point,destination_point,alpha)

func execute_long(delta:float):
	if direction == DIRECTION.forawrd:
		alpha += speed * delta
	else:
		alpha -= speed * delta
	position = lerp(starting_point,destination_point,alpha)
	
	if alpha > 1.0 or alpha < 0.0:
		change_direction()

func change_direction():
	if direction == DIRECTION.forawrd:
		direction = DIRECTION.backward
	else:
		direction = DIRECTION.forawrd
