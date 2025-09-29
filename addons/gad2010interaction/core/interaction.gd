class_name Interaction extends Node

@export_group("General")
## What type of interaction does this node respond to?
@export var interaction_type:Type = Type.SHORT
## Is interaction currently allowed?
@export var enabled: bool = true:
	get:
		return enabled
	set(value):
		var old = enabled
		enabled = value
		if old != value:
			enabled_changed.emit(value)
## Is this a one-and-done style interaction?
@export var one_shot: bool = false
@export_group("Long Interactions")
## How long does this interaction need to be maintained before it's complete?
@export var duration:float = 1
## How does this interaction handle interruptions?
@export var progress_method:ProgressMethod = ProgressMethod.RESET
## Interaction will reset if left alone for this long (seconds)
@export var timeout:float = 0.1

## The current phase of the long interaction (read only)
var phase:Phase:
	get:
		return _phase

var _timer:float
var _timeout_start:float
var _phase:Phase = Phase.CANCELLED
var _timed_out:bool = false

## Emitted when a short interaction is successful
signal short_interaction(instigator:Node)
## Emitted when a long interaction has been maintained to completion
signal long_interaction(instigator:Node, phase:Phase, delta:float)
## Emitted when an interaction is attempted, but not allowed
signal failed_interaction(instigator:Node, interaction_type:Type)
## Emits whenever the progress towards a long interaction changes
signal percent_changed(new_percent:float)
## Emitted when the interaction is enabled or disabled
signal enabled_changed(new_enabled:bool)

func _process(delta):
	if _phase == Phase.STARTED or _phase == Phase.CONTINUED:
		if _timeout_start + timeout * 1000 <= Time.get_ticks_msec():
			_phase = Phase.CANCELLED
			long_interaction.emit(null, Phase.CANCELLED, 0)
			_timed_out = true
	elif _phase == Phase.CANCELLED:
		if progress_method == ProgressMethod.DECAY:
			if _timer > 0:
				_timer = max(0, _timer - delta)
				percent_changed.emit(get_percent())

## Check that this node supports a specific [param type] of interaction
func supports_interaction_type(type:Type) -> bool:
	return (interaction_type == type or interaction_type == Type.ANY) and enabled

## Attempt to trigger the short interaction on this node.
func trigger_short_interaction(instigator:Node) -> bool:
	if supports_interaction_type(Type.SHORT):
		short_interaction.emit(instigator)
		enabled = !one_shot
		return true
	failed_interaction.emit(instigator, Type.SHORT)
	return false

## Does this long interaction progress forever?
func is_endless() -> bool:
	return duration < 0

## How far progressed is this long interaction (0 - 1)
func get_percent() -> float:
	if is_endless():
		return 1
	return clampf(_timer / duration, 0, 1)

## Attempt to progress the long interaction on this node by [param delta] seconds.
func trigger_long_interaction(instigator:Node, delta:float) -> bool:
	if delta <= 0 or !supports_interaction_type(Type.LONG):
		failed_interaction.emit(instigator, interaction_type)
		return false
	match _phase:
		Phase.COMPLETED:
			_phase = Phase.STARTED
			_timer = 0
		Phase.CANCELLED:
			if progress_method == ProgressMethod.RESET:
				_timer = 0
			_phase = Phase.CONTINUED if _timer > 0 else Phase.STARTED
		Phase.STARTED, Phase.CONTINUED:
			_phase = Phase.CONTINUED
	_timer = clampf(_timer + delta, 0, duration)
	if _timer < duration or is_endless():
		_phase = Phase.CONTINUED
	else:
		_phase = Phase.COMPLETED
		enabled = !one_shot
	percent_changed.emit(get_percent())
	long_interaction.emit(instigator, _phase, delta)
	_timed_out = false
	_timeout_start = Time.get_ticks_msec()
	return true

## The current state of a long interaction
enum Phase {
	## The (long) interaction has just been initiated
	STARTED,
	## The interaction is underway but not yet complete
	CONTINUED,
	## The interaction was maintained for the target duration
	COMPLETED,
	## The interaction was stopped before completion
	CANCELLED
}

## How a long interaction behaves when not engaged
enum ProgressMethod {
	RESET,
	MAINTAIN,
	DECAY
}

## What form of interaction is expected by a node
enum Type {
	## A single-press interaction by the player
	SHORT,
	## A long-press (hold) interaction by the player
	LONG,
	## Both short and long interactions fire on this node
	ANY
}
