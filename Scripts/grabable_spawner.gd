class_name GrabableSpawner extends Activatable

@export var create_on_ready:bool = true
@export var scene:PackedScene
@export var respawn_time:float = 1.0

@export var disabled_modulate:Color = Color.WHITE
@onready var default_modulate:Color = modulate

var new_grabable:Grabable

var active:bool = true:
	set(value):
		if value == false:
			modulate = disabled_modulate
			if new_grabable:
				new_grabable.request_drop.emit()
		if value == true:
			modulate = default_modulate
			create_grabable()
		active = value

func _ready() -> void:
	if create_on_ready:
		create_grabable()

func execute():
	active = !active

func create_grabable():
	new_grabable = scene.instantiate()
	add_child(new_grabable)
	new_grabable.global_position = global_position
	new_grabable.queued_destruction.connect(_grabable_destroyed)

func _grabable_destroyed():
	await get_tree().create_timer(respawn_time).timeout
	if active:
		create_grabable()
