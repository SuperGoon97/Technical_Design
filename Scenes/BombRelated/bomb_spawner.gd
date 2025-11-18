extends Activatable

const BOMB = preload("res://Scenes/BombRelated/bomb.tscn")

@export var bomb_initial_direction:Vector2 = Vector2(0.0,0.0)
@export var bomb_initial_speed:float = 100.0
@onready var bomb_spawn_point: Node2D = $BombSpawnPoint
@onready var bomb_initial_velocity = bomb_initial_direction * bomb_initial_speed

func execute():
	spawn_bomb()

func spawn_bomb():
	var new_bomb:RigidBody2D = BOMB.instantiate()
	var deviation:Vector2 = Vector2(randf_range(-1.0,1.0),randf_range(-1.0,1.0))
	add_child(new_bomb)
	new_bomb.global_position = bomb_spawn_point.global_position + deviation
	new_bomb.linear_velocity = bomb_initial_velocity
