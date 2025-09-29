@tool
extends EditorPlugin

# This is a plugin setup script. You should use something similar for your own work.

func _enter_tree() -> void:
	add_custom_type("Interaction", "Node", preload("res://addons/gad2010interaction/core/interaction.gd"), preload("res://addons/gad2010interaction/icons/interaction.png"))
	add_custom_type("InteractionArea2D", "Area2D", preload("res://addons/gad2010interaction/core/interaction_area_2d.gd"), preload("res://addons/gad2010interaction/icons/interaction_area.png"))
	add_custom_type("InteractionBody2D", "StaticBody2D", preload("res://addons/gad2010interaction/core/interaction_body_2d.gd"), preload("res://addons/gad2010interaction/icons/interaction_body.png"))
	add_custom_type("Interactor2D", "Area2D", preload("res://addons/gad2010interaction/core/interactor_2d.gd"), preload("res://addons/gad2010interaction/icons/interactor.png"))

func _exit_tree() -> void:
	remove_custom_type("Interaction")
	remove_custom_type("InteractionArea2D")
	remove_custom_type("InteractionBody2D")
	remove_custom_type("Interactor2D")
