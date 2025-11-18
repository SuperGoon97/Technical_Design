extends Node2D

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	gpu_particles_2d.one_shot = true
	await get_tree().create_timer(1.0).timeout
	call_deferred("queue_free")
