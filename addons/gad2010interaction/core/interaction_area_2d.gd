@tool
class_name InteractionArea2D extends Area2D

var interaction_node:Interaction:
	get:
		if interaction_node == null:
			for child in get_children():
				if child is Interaction:
					interaction_node = child
			if interaction_node == null:
				var interaction = Interaction.new()
				interaction.enabled = false
				interaction_node = interaction
				add_child(interaction)
		return interaction_node

func _get_configuration_warnings() -> PackedStringArray:
	for child in get_children():
		if child is Interaction:
			return []
	return ["This node will not produce a response. Add an Interaction node as a child"]
