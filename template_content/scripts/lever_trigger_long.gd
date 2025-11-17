@tool extends LevelTrigger

@export var array_activatables:Array[Activatable]
func _on_interaction_long_interaction(_instigator: Node, phase: Interaction.Phase, delta: float) -> void:
	if phase == Interaction.Phase.CONTINUED:
		for activatable in array_activatables:
			activatable.execute_long(delta)
