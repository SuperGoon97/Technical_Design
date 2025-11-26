class_name ActivatableIntermediate extends Activatable

@export var activations_required:int = 1
@export var activatables_array:Array[Activatable]
@export var event_to_emit:String
var times_activated = 0

func execute():
	times_activated += 1
	if times_activated >= activations_required:
		activate()

func activate():
	for activatable in activatables_array:
		activatable.execute()
	if event_to_emit:
		signal_bus.event.emit(event_to_emit)
