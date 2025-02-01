extends Node3D

# create a variable to store the PPRootNode
var pp_root_node
# create a variable to handle movement speed
var speed = 5.0
var sprintSpeed = 10
var totalSpeed = speed	
var stamina = 100
var canRestore = true
var isRestoring = true
# create a variable for check if its moving
var is_moving = false

@onready var neck := $CharacterBody3D/Neck
@onready var camera := $CharacterBody3D/Neck/Camera3D
@onready var headbob: AnimationPlayer = $CharacterBody3D/headbob
@onready var stepgrass: AudioStreamPlayer3D = $CharacterBody3D/stepgrass
@onready var pause_menu: Control = $pause_menu

# when the scene is loaded
func _ready() -> void:
	# access the PPRootNode from the scene's node tree 
	pp_root_node = get_tree().current_scene.get_node('PPRootNode')
	assert(pp_root_node, "PPRootNode not found") 
	
	# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode")
	if pp_entity_node:
		pp_entity_node.state_changed.connect(_on_state_changed)
	else:
		print("PPEntityNode not found")
		
func _on_state_changed(state):
	# sync the player's position, using the server's values
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	var diff_in_position = (global_transform.origin - Vector3(state.x, state.z, -state.y)).abs() 
	if diff_in_position > Vector3(1,1,1):
		global_transform.origin = Vector3(state.x, state.z, -state.y)

func _process(delta: float) -> void:
	if(isRestoring):
		isRestoring = stamina != 100
	
	if(canRestore):
		stamina = stamina + 0.5
	
	# get the raw input values
	var input_direction = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forward") 
	)
	# calculate the input direction
	input_direction = (neck.transform.basis * Vector3(input_direction.x, 0, input_direction.z)).normalized()
	
	
	
	# move the player
	if(Input.is_action_pressed("sprint") and Input.is_action_pressed("move_forward") and !isRestoring):
		totalSpeed = speed + sprintSpeed
		stamina = stamina - 0.5
		canRestore = false
		isRestoring = stamina <= 0
	else:
		totalSpeed = speed
		canRestore = true	
	
	var movement = input_direction * totalSpeed * delta
	is_moving = movement.length() > 0.01
	translate(movement)
	
	if Input.is_action_just_pressed("pause_button"):
		openmenu()
	
	if is_moving and Menusettings.headbob_enable:
		headbob.play("headbob")
	elif is_moving and not Menusettings.headbob_enable:
		headbob.play("stepsounds")
	else:
		headbob.pause()
		
		
	# message the server to update the player's x and y positions
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	pp_root_node.message({
		"x": movement[0],
		"y": -movement[2], 
		"z": 0,
	})

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x*0.005)
			camera.rotate_x(-event.relative.y*0.005)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func openmenu():
	if Menusettings.pausemenu_state:
		pause_menu.show()
		
	else:
		pause_menu.hide()
	Menusettings.pausemenu_state = !Menusettings.pausemenu_state


func play_step():
	# stepgrass.pitch_scale = randf_range(.8,1.2)
	stepgrass.play()
