@tool
class_name LevelTrigger extends InteractionArea2D

var is_on:bool = false
## A simple one-shot short interaction.
## The level will flip positions when triggered.
func _on_short_interaction(_instigator):
	if $AnimatedSprite2D.animation == "On":
		$AnimatedSprite2D.play("Off")
		is_on = false
	else:
		$AnimatedSprite2D.play("On")
		is_on = true


func _on_interaction_long_interaction(_instigator: Node, _phase: Interaction.Phase, _delta: float) -> void:
	pass # Replace with function body.
