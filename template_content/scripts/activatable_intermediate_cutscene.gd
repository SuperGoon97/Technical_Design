extends ActivatableIntermediate

@export var camera_targets:Array[AdvancedCameraTarget]

func activate():
	for target in camera_targets:
		target.execute_actions()
	await get_tree().create_timer(1.0).timeout
	super()

func debug_overwrite(string:String):
	if string == overwrite_event:
		activate()
