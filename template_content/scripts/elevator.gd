@tool extends MovingPlatformSimple

@export_tool_button("Destroy Ghost","ActionCut") var action = destroy_ghost_button

@export var camera_target:AdvancedCameraTarget = null
@export var ghost_modulate:Color = Color.WHITE:
	set(value):
		ghost_modulate = value
		update_ghost_color()
@onready var interaction: Interaction = $InteractionArea2D/Interaction
@export_storage var sprite_collection: Node2D:
	get():
		sprite_collection = $SpriteCollection
		return sprite_collection
@export_storage var ghost_node: Node2D:
	get():
		if ghost_node == null:
			ghost_node = sprite_collection.duplicate(15)
			add_child(ghost_node)
			update_ghost_color()
			update_ghost_position()
		return ghost_node

func _init() -> void:
	vector_to_add_changed.connect(update_ghost_position)

func destroy_ghost_button():
	ghost_node.queue_free()
	

func update_ghost_position():
	ghost_node.position = vector_to_add_to_position

func update_ghost_color():
	if ghost_node:
		ghost_node.modulate = ghost_modulate

func _ready() -> void:
	if !Engine.is_editor_hint():
		ghost_node.queue_free()
		interaction.long_interaction.connect(check_phase)

func check_phase(_instigator:Node, phase:Interaction.Phase, _delta:float):
	if phase == Interaction.Phase.COMPLETED:
		if camera_target:
			camera_target.execute_actions()
		execute()

func execute():
	super()
