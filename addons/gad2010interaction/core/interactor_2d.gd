@tool
class_name Interactor2D extends Area2D

## The node responsible for instigating interactions, usually the main player scene. Defaults to this node if left blank
@export var instigator:Node

var _contacts:Array[Node2D]

## Emitted when a new interaction is overlapped or hit
signal interaction_entered(node:Node2D, interaction:Interaction)
## Emitted when an interaction is exited
signal interaction_exited(node:Node2D, interaction:Interaction)

func _ready() -> void:
	area_entered.connect(_entered)
	area_exited.connect(_exited)
	body_entered.connect(_entered)
	body_exited.connect(_exited)
	if owner == null:
		owner = self

func _entered(node:Node2D):
	if node is InteractionArea2D or node is InteractionBody2D:
		if _contacts.find(node) > -1:
			return
		_contacts.insert(0, node)
		interaction_entered.emit(node, node.interaction_node)
	
func _exited(node:Node2D):
	var index := _contacts.find(node)
	if index > -1:
		_contacts.remove_at(index)
		interaction_exited.emit(node, node.interaction_node)

## Attempt a short interaction with the first suitable overlapped area. Returns an object containing 2 values: success (bool) and node (Node2D)
func attempt_short_interaction() -> ShortInteractionInfo:
	var info:ShortInteractionInfo = ShortInteractionInfo.new()
	for node in _contacts:
		if node.interaction_node.trigger_short_interaction(instigator):
			info.success = true
			info.node = node
			return info
	return info

## Attempt a long interaction with the first suitable overlapped area. If possible, progress it by [param delta] seconds.
## Returns an object containing values for: success (bool), node (Node2D) and phase (Interaction.Phase)
func attempt_long_interaction(delta:float) -> LongInteractionInfo:
	var info:LongInteractionInfo = LongInteractionInfo.new()
	for node in _contacts:
		if node.interaction_node.trigger_long_interaction(instigator, delta):
			info.success = true
			info.node = node
			info.phase = node.interaction_node.phase
			return info
	return info

## Returns all Interactions that are in contact AND active
func get_enabled_interactions() -> Array[Interaction]:
	var results:Array[Interaction] = []
	for node in _contacts:
		if node.interaction_node.enabled:
			results.append(node.interaction_node)
	return results

class ShortInteractionInfo extends RefCounted:
	## Was the interaction successful?
	var success:bool
	## The node targeted by the interaction
	var node:Node2D

class LongInteractionInfo extends RefCounted:
	## Was the interaction successful?
	var success:bool
	## The node targeted by the interaction
	var node:Node2D
	## The current phase of the long interaction
	var phase:Interaction.Phase = Interaction.Phase.CANCELLED
