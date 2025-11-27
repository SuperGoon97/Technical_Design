extends Area2D

var player:GAD2010Character = null
@export var direction:int = 1
func _ready() -> void:
	area_entered.connect(_on_overlap)

func _on_overlap(area:Area2D):
	if area.get_parent() is GAD2010Character:
		player = area.get_parent()

func _physics_process(_delta: float) -> void:
	if player:
		player.player_can_move = false
		player.velocity.x = float(direction) * player.SPEED
		player._sprite.play("walk")
		player._sprite.flip_h = direction < 0
