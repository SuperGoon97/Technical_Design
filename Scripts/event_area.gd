extends Area2D

@export var event_string_to_emit:String
@export var do_once:bool = true
var can_execute:bool = true
func _init() -> void:
	area_entered.connect(on_area_entered)

func on_area_entered(area:Area2D):
	if !can_execute: return
	if area.get_parent() is GAD2010Character:
		signal_bus.event.emit(event_string_to_emit)
	if do_once:
		can_execute = false
