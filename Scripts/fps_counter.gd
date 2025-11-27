class_name FpsCounter
extends Label

func _ready() -> void:
	if debug.FPS_DEBUG == false:
		queue_free()

func _process(_delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	text = "FPS: " + str(fps)
