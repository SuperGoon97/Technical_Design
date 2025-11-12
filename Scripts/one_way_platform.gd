class_name OneWayPlatform extends Node2D

@onready var static_body_2d: AnimatableBody2D = $StaticBody2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_base_scale:Vector2 = sprite_2d.scale
var platform_speed:float = 10.0
var platform_targets:Array[Node2D]
var target:int = 0
var is_active:bool = true:
	set(value):
		is_active = value
		if value:
			target = 0
		else:
			target = 1
func _physics_process(delta: float) -> void:
	if platform_targets.is_empty(): 	return
	var direction = (platform_targets[target].position - position).normalized()
	var distance = position.distance_to(platform_targets[target].position)
	var velocity = direction * platform_speed * delta
	if distance < 1.0:
		if is_active:
			send_to_background()
		else:
			send_to_front()
	position += velocity

func send_to_background():
	sprite_2d.z_index -=1
	is_active = false
	toggle_layer_collision(false)
	tween_color(Color.DIM_GRAY)
	tween_size(Vector2(0.9,0.9))

func send_to_front():
	sprite_2d.z_index +=1
	is_active = true
	toggle_layer_collision(true)
	tween_color(Color.WHITE)
	tween_size(Vector2(1.0,1.0))

func tween_color(input:Color):
	var new_tween:Tween = create_tween()
	new_tween.tween_property(self,"modulate",input,0.2)

func tween_size(input:Vector2):
	var new_tween:Tween = create_tween()
	new_tween.tween_property(sprite_2d,"scale",input*sprite_2d_base_scale,0.2)

func toggle_layer_collision(state:bool):
	static_body_2d.set_collision_layer_value(1,state)
	static_body_2d.set_collision_mask_value(1,state)
	
