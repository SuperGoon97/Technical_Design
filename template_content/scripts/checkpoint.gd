class_name Checkpoint extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_set_checkpoint)

func _set_checkpoint(body:Node2D) -> void:
	if body is GAD2010Character:
		body.set_checkpoint(self)
