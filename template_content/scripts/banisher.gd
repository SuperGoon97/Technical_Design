class_name Banisher extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_banish)

func _banish(body:Node2D) -> void:
	if body is GAD2010Character:
		body.banish()
