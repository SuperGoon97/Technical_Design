@tool
class_name BlockingWall extends InteractionBody2D

# Player must be in physical contact with the object to trigger this.
func _on_short_interaction(_instigator):
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0,128), 1)
	tween.play()
