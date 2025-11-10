@tool 
extends InteractionArea2D

@onready var platform: Node2D = $Platform

func _on_interaction_short_interaction(_instigator: Node) -> void:
	platform.rotate(deg_to_rad(45))


func _on_interaction_long_interaction(_instigator: Node, _phase: Interaction.Phase, _delta: float) -> void:
	platform.rotate(deg_to_rad(1))
