extends Activatable

const R_G_GRADIENT = preload("res://Scenes/BombRelated/r_g_gradient.tres")


@export var is_active:bool = true:
	set(value):
		is_active = value
		set_active_state(is_active)
@export var disabled_color:Color = Color.WHITE
@export var hits_required:int = 1
@export var activatables_array:Array[Activatable]

@onready var state_sprite: Sprite2D = $StateSprite
@onready var state_sprite_color:Color = R_G_GRADIENT.sample(0.0)
@onready var defualt_color:Color = modulate

func _ready() -> void:
	state_sprite.modulate = state_sprite_color

var cum_hits:int = 0:
	set(value):
		cum_hits = value
		if cum_hits == hits_required:
			execute_activatables()

func execute_activatables():
	for activatable in activatables_array:
		activatable.execute()

func execute():
	set_active_state(!is_active)

func set_active_state(state:bool):
	if state:
		modulate = defualt_color
	else:
		modulate = disabled_color

func on_hit_by_bomb():
	if cum_hits <= hits_required:
		cum_hits += 1
		state_sprite_color = R_G_GRADIENT.sample(float(cum_hits)/float(hits_required))
		state_sprite.modulate = state_sprite_color
