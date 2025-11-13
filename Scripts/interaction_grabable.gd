@tool
class_name Grabable extends InteractionArea2D

signal queued_destruction
signal request_drop

var held = false
@onready var scene_parent:Node = get_parent()

func _init() -> void:
	interaction_node.interaction_type = interaction_node.Type.SHORT
	interaction_node.enabled = true

func _ready() -> void:
	interaction_node.short_interaction.connect(_on_interaction_short_interaction)
	request_drop.connect(_destroy)
	
func _on_interaction_short_interaction(instigator: Node) -> void:
	if instigator is GAD2010Character:
		if held:
			_drop(instigator)
		elif instigator.is_holding_grabable == false:
			_grabbed(instigator)

func _grabbed(instigator: GAD2010Character):
	global_position = instigator.grab_position.global_position
	reparent(instigator.grab_position)
	instigator.is_holding_grabable = true
	instigator.held_grabable = self
	held = true
	_activate_effect(instigator)

func _drop(instigator: GAD2010Character):
	instigator.is_holding_grabable = false
	reparent(scene_parent)
	held = false
	_disable_effect(instigator)
	_destroy()

func _destroy():
	queued_destruction.emit()
	call_deferred("queue_free")

func _activate_effect(_instigator: GAD2010Character):
	return

func _disable_effect(_instigator: GAD2010Character):
	return
