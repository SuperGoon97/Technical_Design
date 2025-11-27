class_name ActivatableIntermediate extends Activatable

@export var activations_required:int = 1
@export var activatables_array:Array[Activatable]
@export var event_to_emit:String
@export var overwrite_event:String
var times_activated = 0

func _ready() -> void:
	signal_bus.debug_event.connect(debug_overwrite)

func execute():
	times_activated += 1
	if times_activated >= activations_required:
		activate()

func activate():
	for activatable in activatables_array:
		activatable.execute()
	if event_to_emit:
		signal_bus.event.emit(event_to_emit)

func debug_overwrite(string:String):
	if string == overwrite_event:
		for activatable in activatables_array:
			activatable.execute()
