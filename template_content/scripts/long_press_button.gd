@tool
extends InteractionArea2D

## A simple response to a one-shot long interaction.
## This button will show as pressed while the player is in range and holding the interact key.
func _on_interaction_long_interaction(_instigator, phase, _delta):
	match  phase:
		Interaction.Phase.CONTINUED, Interaction.Phase.COMPLETED:
			$AnimatedSprite2D.play("active_pressed")
		Interaction.Phase.CANCELLED:
			$AnimatedSprite2D.play("active_up")
