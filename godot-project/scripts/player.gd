extends Node3D

# create a variable to store the PPRootNode
var pp_root_node
# create a variable to handle movement speed
var speed:int = 5
var sprintSpeed:int = 10
var totalSpeed:int = speed	
var stamina:float = 100
var maxstamina:float = 100
var staminarate:float = 0.5
var canRestore:bool = true
var isRestoring:bool = false

# create a variable for check if its moving
var is_moving:bool = false
#variable related to tools
var tool_inhand:int = 1
# variables related to attack
var is_attacking : bool = false
@export var stamina_attack_cap:int = 35

var player_wood:int = 0
var player_water:int = 0


@onready var character_body_3d: CharacterBody3D = $CharacterBody3D
@onready var neck := $CharacterBody3D/Neck
@onready var camera := $CharacterBody3D/Neck/Camera3D
@onready var headbob: AnimationPlayer = $CharacterBody3D/Neck/headbob
@onready var stepgrass: AudioStreamPlayer3D = $CharacterBody3D/stepgrass
@onready var pause_menu: Control = $pause_menu
@onready var bar_stamina: TextureProgressBar = $bar_stamina
@onready var axe_animation: AnimationPlayer = $CharacterBody3D/Neck/Camera3D/Axe/axe_animation
@onready var axe_hitbox: Area3D = $CharacterBody3D/Neck/Camera3D/Axe/MeshInstance3D/axe_hitbox
@onready var axeswing: AudioStreamPlayer3D = $CharacterBody3D/Neck/Camera3D/Axe/MeshInstance3D/axeswing
@onready var axe: Node3D = $CharacterBody3D/Neck/Camera3D/Axe
@onready var taser: Node3D = $CharacterBody3D/Neck/Camera3D/taser
@onready var taser_animation: AnimationPlayer = $CharacterBody3D/Neck/Camera3D/taser/taser_animation
@onready var taser_hitbox: Area3D = $CharacterBody3D/Neck/Camera3D/taser/MeshInstance3D/taser_hitbox
@onready var taserattack: AudioStreamPlayer3D = $CharacterBody3D/Neck/Camera3D/taser/taserattack
@onready var waterpump: Node3D = $CharacterBody3D/Neck/Camera3D/waterpump
@onready var bar_wood: TextureProgressBar = $bar_wood
@onready var bar_water: TextureProgressBar = $bar_water
@onready var interact_ray: RayCast3D = $CharacterBody3D/Neck/Camera3D/InteractRay




# when the scene is loaded
func _ready() -> void:
	# access the PPRootNode from the scene's node tree 
	pp_root_node = get_tree().current_scene.get_node('PPRootNode')
	assert(pp_root_node, "PPRootNode not found") 
	
	# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode");
	pp_root_node.message({"color": {
		"r": randf()/4,
		"g": randf()/4, 
		"b": randf()/4
	}});
	
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
	openmenu()
	axeattack()
	stunattack()
	swaptool()
	headbobhandle()
	staminahandle()

	
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
	
	# message the server to update the player's x and y positions
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	pp_root_node.message({
		"x": movement[0],
		"y": -movement[2], 
		"z": 0,
		"rotation":neck.rotation.y
	});

func _physics_process(delta: float) -> void:
	if $CharacterBody3D/Neck/Camera3D/InteractRay.is_colliding():
		var target = $CharacterBody3D/Neck/Camera3D/InteractRay.get_collider()
		if target != null and target.has_method("interact"):
			if Input.is_action_pressed("interact"):
				target.interact(delta, Input.get_action_strength("interact"))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Menusettings.pausemenu_state:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	elif event.is_action_pressed("ui_cancel"):
		if Menusettings.pausemenu_state:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.MOUSE_MODE_CAPTURED and Menusettings.pausemenu_state:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x*0.005)
			camera.rotate_x(-event.relative.y*0.005)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

#handles stamina stat and value in bar
func staminahandle():
	if(isRestoring):
		isRestoring = stamina != maxstamina+0.1
	if(canRestore and stamina < maxstamina): 
		stamina = stamina + staminarate
	$bar_stamina.value = stamina	



#handles menu in game
func openmenu():
	if Input.is_action_just_pressed("pause_button"):
		if Menusettings.pausemenu_state:
			pause_menu.show()
		else:
			pause_menu.hide()
	Menusettings.pausemenu_state = !Menusettings.pausemenu_state

#handles headbob and config of it
func headbobhandle():
	if is_moving and Menusettings.headbob_enable:
		headbob.play("headbob")
		
	elif is_moving and not Menusettings.headbob_enable:
		headbob.play("stepsounds")
		
	else:
		headbob.pause()
# made for being called later in the headbob animation so the steps are on time
func play_step():
	# stepgrass.pitch_scale = randf_range(.8,1.2)
	stepgrass.play()

#handles axe attacks
func axeattack():
	if tool_inhand == 1 and Input.is_action_just_pressed("attack") and not is_attacking and Menusettings.pausemenu_state and stamina > stamina_attack_cap :
		is_attacking = true
		axe_animation.play("attack_animation")
		axe_hitbox.monitoring = true
		axeswing.pitch_scale = randf_range(.8,1.2)
		axeswing.play()
		stamina = stamina -stamina_attack_cap
func _on_axe_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack_animation":
		axe_animation.play("idle_axe_animation")
		axe_hitbox.monitoring = false
		is_attacking=false
func _on_axe_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("arbol"):
		print("Tree hitted")
		player_wood += 1
	$bar_wood.value = player_wood

# handle stun weapon with enemies
func stunattack():
	if tool_inhand == 2 and Input.is_action_just_pressed("attack") and not is_attacking and Menusettings.pausemenu_state and stamina > stamina_attack_cap :
			is_attacking = true
			taser_animation.play("taser_attack")
			taser_hitbox.monitoring = true
			taserattack.pitch_scale = randf_range(.8,1.2)
			taserattack.play()
			stamina = stamina -stamina_attack_cap
func _on_taser_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "taser_attack":
		taser_animation.play("reset")
		taser_animation.play("idle_taser")
		taser_hitbox.monitoring = false
		is_attacking=false
		taserattack.stop()
func _on_taser_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("gato"):
		print("enemy hitted")
		

#handles tool selection
func swaptool() -> void:
		if Input.is_action_just_pressed("swaptool_up") and tool_inhand < 3:
			tool_inhand += 1
			#print(tool_inhand)
			is_attacking=false
		if Input.is_action_just_pressed("swaptool_down") and tool_inhand > 1:
			tool_inhand -= 1
			#print(tool_inhand)
			is_attacking=false
		match tool_inhand:
			1:
				axe.show()
				taser.hide()
				waterpump.hide()
			2:
				axe.hide()
				taser.show()
				waterpump.hide()
			3:
				axe.hide()
				taser.hide()
				waterpump.show()


		
