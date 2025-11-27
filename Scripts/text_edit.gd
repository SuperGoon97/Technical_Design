extends TextEdit

@onready var button: Button = $Button

func _ready() -> void:
	if debug.EVENT_DEBUG == false:
		queue_free()
	button.button_down.connect(execute)
	
func execute():
	signal_bus.debug_event.emit(text)
