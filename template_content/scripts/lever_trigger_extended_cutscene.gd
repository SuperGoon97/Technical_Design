@tool extends LeverTriggerExtended

@export var camera_targets:Array[AdvancedCameraTarget]

func _on_short_interaction(_instigator):
	for target in camera_targets:
		target.execute_actions()
	await get_tree().create_timer(1.0).timeout
	super(_instigator)
	
