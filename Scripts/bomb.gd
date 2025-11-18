extends RigidBody2D

const BOMB_PARTICLE = preload("res://Scenes/BombRelated/bomb_particle.tscn")

@onready var timer: Timer = $Timer
@onready var area_2d: Area2D = $Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var flash_time:float = 1.0
var sum_flash_times = 0.0
var tween:Tween

func _ready() -> void:
	start_fuse()

func start_fuse():
	timer.start()
	start_tweens()
	pass

func explode():
	var new_particle:Node2D = BOMB_PARTICLE.instantiate()
	get_tree().current_scene.add_child(new_particle)
	new_particle.global_position = global_position
	interact_overlapping()
	call_deferred("queue_free")

func interact_overlapping():
	var overlapping_areas:Array[Area2D] = area_2d.get_overlapping_areas()
	for area in overlapping_areas:
		var parent_node:Node = area.get_parent()
		if parent_node.has_method("on_hit_by_bomb"):
			print("on hit by bomb invoked")
			parent_node.on_hit_by_bomb()

func _on_timer_timeout() -> void:
	explode()
	pass # Replace with function body.

func start_tweens():
	tween = create_tween().set_parallel(true)
	tween.pause()
	var i:int = 0
	var color:Color
	var vec:Vector2
	while sum_flash_times < timer.wait_time:
		print(i)
		if i%2 > 0:
			color = Color.RED
			vec = Vector2(1.0+((i+1)*0.05),1.0+((i+1)*0.05))
		else:
			color = Color.WHITE
			vec = Vector2(1.0,1.0)
		tween.tween_property(sprite_2d,"modulate",color,flash_time)
		tween.tween_property(sprite_2d,"scale",vec,flash_time)
		tween.chain()
		sum_flash_times += flash_time
		flash_time = clampf(flash_time/2.0,0.25,1.0)
		i += 1
	tween.play()
