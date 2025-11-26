extends Node2D

@onready var boss_animation_player: AnimationPlayer = $BossAnimationPlayer
@onready var phase_begin_camera_actions: AdvancedCameraTarget = $PhaseBeginCameraActions
@onready var phase_end_camera_actions: AdvancedCameraTarget = $PhaseEndCameraActions

func _ready() -> void:
	visible = false
	signal_bus.event.connect(event_switch)
	
func event_switch(string:String):
	print(string)
	match string:
		"boss_entered":
			boss_entered()
		"phase_1_end":
			phase_1_end()
		"phase_2_end":
			phase_2_end()

## Called when player enters arena
func boss_entered():
	await get_tree().create_timer(3.0).timeout
	print("play anim 1")
	boss_animation_player.play("boss_appear_animation")
	await boss_animation_player.animation_finished
	print("play anim 2")
	boss_animation_player.play("key_to_boss_animation")
	await boss_animation_player.animation_finished
	signal_bus.event.emit("phase_1")

func phase_1_end():
	phase_end_camera_actions.execute_actions()
	await get_tree().create_timer(1.0).timeout
	boss_animation_player.play_backwards("boss_appear_animation")
	await boss_animation_player.animation_finished
	global_position = get_tree().get_first_node_in_group("BossPos2").global_position
	phase_begin_camera_actions.execute_actions()
	await get_tree().create_timer(1.0).timeout
	boss_animation_player.play("boss_appear_animation")
	signal_bus.event.emit("phase_2")

func phase_2_end():
	phase_end_camera_actions.execute_actions()
	await get_tree().create_timer(1.0).timeout
	boss_animation_player.play_backwards("boss_appear_animation")
	await boss_animation_player.animation_finished
	global_position = get_tree().get_first_node_in_group("BossPos3").global_position
	phase_begin_camera_actions.execute_actions()
	await get_tree().create_timer(1.0).timeout
	boss_animation_player.play("boss_appear_animation")
	signal_bus.event.emit("phase_3")
