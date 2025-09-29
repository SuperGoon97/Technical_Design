@tool
class_name LevelEntry extends InteractionArea2D

@export var level_path:String = "res://template_content/scenes/encounter_hub.tscn"

func _on_long_interaction(_instigator, phase, _delta):
	if phase == Interaction.Phase.COMPLETED:
		get_tree().call_deferred("change_scene_to_file", level_path)
