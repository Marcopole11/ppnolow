extends MultiplayerSynchronizer

const Player = preload("uid://b31clmuucjndl")

@export var input_direction:Vector3
@export var sprinting:bool
@export var cameraMovement:Vector2
@export var interact:bool
@export var actionFlash:bool
@export var itemSwap:String = ""
@export var actionAttack:bool
@export var actionAttackRelease:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var isInputEnabled = get_multiplayer_authority() == multiplayer.get_unique_id()
	set_process(isInputEnabled)
	set_physics_process(isInputEnabled)
	set_process_unhandled_input(isInputEnabled)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if not get_window().has_focus():
		return
		
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		print("Problem!!!!!!")
	input_direction = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forward") 
	)
	sprinting = Input.is_action_pressed("sprint") and Input.is_action_pressed("move_forward")
	
	if Input.is_action_just_pressed("interact"):
		trigger_interact.rpc()
		
	if Input.is_action_just_pressed("flash"):
		trigger_action_flash.rpc()
		
		
	if Input.is_action_just_pressed("swaptool_up"):
		trigger_tool_swap.rpc("UP")
	elif Input.is_action_just_pressed("swaptool_down"):
		trigger_tool_swap.rpc("DOWN")
	elif Input.is_action_just_pressed("1tool"):
		trigger_tool_swap.rpc("1")
	elif Input.is_action_just_pressed("2tool"):
		trigger_tool_swap.rpc("2")
	elif Input.is_action_just_pressed("3tool"):
		trigger_tool_swap.rpc("3")
		
	if Input.is_action_just_pressed("attack"):
		trigger_action_attack.rpc()
	elif Input.is_action_just_released("attack"):
		trigger_action_attack_release.rpc()
		
	print("Multiplayer authority ", get_multiplayer_authority(), " has focus: ", get_window().has_focus())

@rpc("authority", "call_local", "unreliable_ordered")
func camera_move(movement:Vector2):
	cameraMovement = movement
	
@rpc("authority", "call_local")
func trigger_interact():
	interact = true

@rpc("authority", "call_local")
func trigger_action_flash():
	actionFlash = true
	
@rpc("authority", "call_local")
func trigger_tool_swap(code:String):
	itemSwap = code
	
@rpc("authority", "call_local")
func trigger_action_attack():
	print("action attack: ", get_multiplayer_authority())
	actionAttack = true
	
@rpc("authority", "call_local")
func trigger_action_attack_release():
	actionAttackRelease = true

func _unhandled_input(event: InputEvent) -> void:
	if not get_window().has_focus():
		return
	
	if Input.MOUSE_MODE_CAPTURED and Menusettings.pausemenu_state:
		if event is InputEventMouseMotion:
			camera_move.rpc(event.screen_relative)
