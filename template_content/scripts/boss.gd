extends Node2D

@onready var boss_animation_player: AnimationPlayer = $BossAnimationPlayer

func _ready() -> void:
	visible = false
	signal_bus.event.connect(event_switch)
	
func event_switch(string:String):
	print(string)
	match string:
		"boss_entered":
			boss_entered()
## Called when player enters arena
func boss_entered():
	await get_tree().create_timer(3.0).timeout
	print("play anim 1")
	boss_animation_player.play("boss_appear_animation")
	await boss_animation_player.animation_finished
	print("play anim 2")
	boss_animation_player.play("key_to_boss_animation")
	
