extends AnimatableBody2D

@export var long_interaction_trigger:InteractionArea2D
@export var end_location:Vector2
@export var movement_duration:float = 3

# For some added reusability, the interaction is bound on start, rather than directly in editor.
func _ready():
	if long_interaction_trigger != null:
		long_interaction_trigger.interaction_node.long_interaction.connect(_move)

func _move(_instigator, phase:Interaction.Phase, _delta):
	if phase == Interaction.Phase.COMPLETED:
		var tween = create_tween()
		tween.tween_property(self, "position", end_location, movement_duration)
		tween.play()
