extends Node2D

@export var hits_required:int = 1
@export var activatables_array:Array[Activatable]
@export var phase_response:String
@export var alt_phase_response:String

@onready var bomb_interactable: BombInteractable = $Node2D/BombInteractable
@onready var animation_player: AnimationPlayer = $Node2D/AnimationPlayer

func _ready() -> void:
	bomb_interactable.hits_required = hits_required
	signal_bus.event.connect(event_switch)


func event_switch(string:String):
	if string == phase_response:
		animation_player.play("appear_animation")
	elif string == alt_phase_response:
		animation_player.play_backwards("appear_animation")
		await animation_player.animation_finished
		call_deferred("queue_free")

func _on_bomb_interactable_cum_hits_reached() -> void:
	for activatable in activatables_array:
		activatable.execute()
	pass # Replace with function body.
