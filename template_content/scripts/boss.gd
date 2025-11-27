extends Node2D

const BOMB_PARTICLE = preload("res://Scenes/BombRelated/bomb_particle.tscn")

@onready var boss_animation_player: AnimationPlayer = $BossAnimationPlayer
@onready var phase_begin_camera_actions: AdvancedCameraTarget = $PhaseBeginCameraActions
@onready var phase_end_camera_actions: AdvancedCameraTarget = $PhaseEndCameraActions

func _ready() -> void:
	visible = false
	signal_bus.event.connect(event_switch)
	signal_bus.debug_event.connect(event_switch)
	
func event_switch(string:String):
	print(string)
	match string:
		"boss_entered":
			boss_entered()
		"phase_1_end":
			phase_1_end()
		"phase_2_end":
			phase_2_end()
		"phase_3_end":
			phase_3_end()

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

func phase_3_end():
	var timer:Timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	timer.one_shot = false
	timer.timeout.connect(create_explosion)
	timer.start()
	phase_end_camera_actions.execute_actions()
	phase_end_camera_actions.camera_actions[1].post_wait = 3.0
	await get_tree().create_timer(3.0).timeout
	boss_animation_player.play_backwards("boss_appear_animation")
	await boss_animation_player.animation_finished
	signal_bus.debug_event.emit("boss_complete")
	call_deferred("queue_free")

func create_explosion():
	var bomb_particle:Node2D = BOMB_PARTICLE.instantiate()
	var root:Node = get_tree().get_first_node_in_group("LevelRoot")
	root.add_child(bomb_particle)
	bomb_particle.global_position = global_position + Vector2(randf_range(-32.0,32.0),randf_range(-32.0,32.0))
