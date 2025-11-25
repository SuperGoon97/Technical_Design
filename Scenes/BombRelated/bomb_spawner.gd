extends Activatable

const BOMB = preload("res://Scenes/BombRelated/bomb.tscn")

@export var bomb_initial_direction:Vector2 = Vector2(0.0,0.0)
@export var bomb_initial_speed:float = 100.0
@export var auto_fire:bool = false
@export var auto_fire_frequency:float = 5.0

var bomb_auto_fire_timer:Timer = null

@onready var bomb_spawn_point: Node2D = $BombSpawnPoint
@onready var attach_node:Node = get_tree().get_first_node_in_group("LevelRoot")

func _ready() -> void:
	if auto_fire:
		bomb_auto_fire_timer = Timer.new()
		add_child(bomb_auto_fire_timer)
		bomb_auto_fire_timer.autostart = true
		bomb_auto_fire_timer.one_shot = false
		bomb_auto_fire_timer.wait_time = auto_fire_frequency
		bomb_auto_fire_timer.timeout.connect(spawn_bomb)
		bomb_auto_fire_timer.start()

func execute():
	spawn_bomb()

func spawn_bomb():
	var new_bomb:RigidBody2D = BOMB.instantiate()
	var bomb_initial_velocity:Vector2 = ((bomb_spawn_point.global_position - global_position).normalized()*bomb_initial_speed)
	var deviation:Vector2 = Vector2(randf_range(-1.0,1.0),randf_range(-1.0,1.0))
	attach_node.add_child(new_bomb)
	new_bomb.global_position = bomb_spawn_point.global_position + deviation
	new_bomb.linear_velocity = bomb_initial_velocity
