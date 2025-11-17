@tool 
class_name LeverTriggerExtended extends LevelTrigger

@export var array_activatables:Array[Activatable]

func _on_short_interaction(_instigator):
	super(_instigator)
	for activatable in array_activatables:
		activatable.execute()
