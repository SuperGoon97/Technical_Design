extends ColorRect

@onready var label: Label = $Label

func _ready() -> void:
	signal_bus.event.connect(fade)
	signal_bus.debug_event.connect(fade)

func fade(string:String):
	if string == "fade_screen":
		var tween:Tween = create_tween()
		tween.tween_property(self,"color",Color(color.r,color.g,color.b,1.0),1.0)
		await tween.finished
		label.visible = true
