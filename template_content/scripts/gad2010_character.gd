class_name GAD2010Character extends CharacterBody2D

const SPEED:float = 300.0
const JUMP_VELOCITY:float = -850.0
const HUB_SCENE_PATH:String = "res://template_content/scenes/encounter_hub.tscn"

## How long does the interact key need to be down to be considered a hold, rather than a press?
@export var hold_threshold:float = 0.2
## How powerful should the shader indicator for an available interaction be?
@export var highlight_power:float = 0.5

@onready var _sprite := $AnimatedSprite2D
@onready var _interactor := $Interactor2D
@onready var _progress_bar := $ProgressBar
@onready var grab_position: Node2D = $GrabPosition

var gravity_multiplier:float = 3.0
var fall_multiplier:float = 1.0

var _held_time:float = -1
var _held_state:HoldState = HoldState.NONE
var _checkpoint:Node2D = null

var player_can_move:bool = true
var is_holding_grabable = false

func _ready() -> void:
	_interactor.interaction_entered.connect(_on_interaction_entered)
	_interactor.interaction_exited.connect(_on_interaction_exited)
	G_Advanced_Cam.camera_action_lock_player.connect(set_player_can_move)

func set_player_can_move(state:bool):
	player_can_move = !state

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		G_Advanced_Cam.move_camera_on.emit()
	if !player_can_move:
		return

	_update_held_state(delta)
	# Add the gravity.
	if not is_on_floor():
		if velocity.y >= 0.0:
			velocity += get_gravity() * delta * gravity_multiplier * fall_multiplier
		else:
			velocity += get_gravity() * delta * gravity_multiplier
	
	if is_on_floor():
		match _held_state:
			HoldState.SHORT_PRESS:
				_interactor.attempt_short_interaction()
				_resolve_highlight()
			HoldState.HOLDING:
				var i = _interactor.attempt_long_interaction(delta)
				if i.success:
					_progress_bar.indeterminate = i.node.interaction_node.is_endless()
					_progress_bar.visible = true
					_progress_bar.value = i.node.interaction_node.get_percent()
					if i.phase == Interaction.Phase.COMPLETED:
						interrupt_interaction()
				else:
					interrupt_interaction()
			_:
				_progress_bar.visible = false
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
			G_Advanced_Cam.move_camera_on.emit()
			interrupt_interaction()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction:float = Input.get_axis("ui_left", "ui_right")
	if _held_state == HoldState.HOLDING:
		direction = 0
	if direction != 0:
		velocity.x = direction * SPEED
		_sprite.play("walk")
		_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if _held_state == HoldState.HOLDING:
			_sprite.play("interact")
		else:
			_sprite.play("idle")
	
	if not is_on_floor():
		_sprite.play("jump")
		
	move_and_slide()

func _update_held_state(delta:float) -> void:
	if Input.is_action_just_pressed("interact"):
		_held_time = 0
		_held_state = HoldState.CHARGING
	if _held_time < 0:
		_held_state = HoldState.NONE
		return
	if Input.is_action_pressed("interact"):
		_held_time += delta
		_held_state = HoldState.HOLDING if _held_time >= hold_threshold else HoldState.CHARGING
	if Input.is_action_just_released("interact"):
		_held_state = HoldState.HOLD_RELEASED if _held_time >= hold_threshold else HoldState.SHORT_PRESS
		_held_time = -1

## Stop the current interaction channeling by the player
func interrupt_interaction() -> void:
	_held_time = -1
	_held_state = HoldState.NONE
	_resolve_highlight()

enum HoldState {
	NONE,
	SHORT_PRESS,
	CHARGING,
	HOLDING,
	HOLD_RELEASED
}

func _on_interaction_entered(_node: Node2D, _interaction: Interaction) -> void:
	_resolve_highlight()

func _on_interaction_exited(_node: Node2D, _interaction: Interaction) -> void:
	_resolve_highlight()

func _resolve_highlight() -> void:
	if _interactor.get_enabled_interactions().size() > 0:
		_sprite.material.set("shader_parameter/Power",highlight_power)
	else:
		_sprite.material.set("shader_parameter/Power",0)

func banish() -> void:
	if _checkpoint == null:
		get_tree().call_deferred("change_scene_to_file", HUB_SCENE_PATH)
	else:
		position = _checkpoint.position

func set_checkpoint(node:Node2D) -> void:
	_checkpoint = node
