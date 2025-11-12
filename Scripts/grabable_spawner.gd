class_name GrabableSpawner extends Node2D

@export var create_on_ready:bool = true
@export var scene:PackedScene
@export var respawn_time:float = 1.0

func _ready() -> void:
	if create_on_ready:
		create_grabable()

func create_grabable():
	var new_scene:Grabable = scene.instantiate()
	add_child(new_scene)
	new_scene.global_position = global_position
	new_scene.queued_destruction.connect(_grabable_destroyed)

func _grabable_destroyed():
	await get_tree().create_timer(respawn_time).timeout
	create_grabable()
