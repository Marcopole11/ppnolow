extends MultiplayerSynchronizer

@export var input_direction:Vector3
@export var sprinting:bool
@export var cameraMovement:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var isInputEnabled = get_multiplayer_authority() == multiplayer.get_unique_id()
	set_process(isInputEnabled)
	set_physics_process(isInputEnabled)
	set_process_unhandled_input(isInputEnabled)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	input_direction = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forward") 
	)
	sprinting = Input.is_action_pressed("sprint") and Input.is_action_pressed("move_forward")

@rpc("authority", "call_local", "unreliable_ordered")
func camera_move(movement:Vector2):
	cameraMovement = movement

func _unhandled_input(event: InputEvent) -> void:
	if Input.MOUSE_MODE_CAPTURED and Menusettings.pausemenu_state:
		if event is InputEventMouseMotion:
			camera_move.rpc(event.screen_relative)
