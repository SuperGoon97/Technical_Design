@tool
extends InteractionArea2D

## A simple one-shot short interaction.
## The level will flip positions when triggered.
func _on_short_interaction(_instigator):
	if $AnimatedSprite2D.animation == "On":
		$AnimatedSprite2D.play("Off")
	else:
		$AnimatedSprite2D.play("On")
