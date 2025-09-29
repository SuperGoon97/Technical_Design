@tool
extends InteractionArea2D

@export var rotation_speed:float = 60

# The duration of this interaction is less than 0, so it will be endless.
func _on_long_interaction(_instigator, _phase, delta):
	$Sprite2D.rotation_degrees += delta * rotation_speed
