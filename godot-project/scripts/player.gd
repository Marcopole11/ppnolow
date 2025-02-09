extends CharacterBody3D
# create a variable to store the PPRootNode
var pp_root_node
# create a variable to handle movement speed
var speed:float = 20
var sprintSpeed:int = 30
var totalSpeed:int = speed	
var stamina:float = 100
var maxstamina:float = 100
var staminarate:float = 0.5
var canRestore:bool = true
var isRestoring:bool = false
var gravity = 1

# create a variable for check if its moving
var is_moving:bool = false
#variable related to tools
var tool_inhand:int = 1
# variables related to attack
var is_attacking : bool = false
@export var stamina_attack_cap:int = 35


var player_wood:int = 0
var player_water:float = 0
var fillingwater_player: bool = false
var waterpumpsound:bool =false

var edgemap_distance:int = 240
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var headbob: AnimationPlayer = $Neck/headbob
@onready var stepgrass: AudioStreamPlayer3D = $stepgrass
@onready var pause_menu: Control = $pause_menu
@onready var bar_stamina: TextureProgressBar = $bar_stamina
@onready var axe_animation: AnimationPlayer = $Neck/Camera3D/Axe/axe_animation
@onready var axe: Node3D = $Neck/Camera3D/Axe
@onready var axeswing: AudioStreamPlayer3D = $Neck/Camera3D/Axe/axeswing
@onready var axe_hitbox: Area3D = $Neck/Camera3D/Axe/MeshInstance3D/axe_hitbox
@onready var waterpump: Node3D = $Neck/Camera3D/waterpump

@onready var interact_ray: RayCast3D = $Neck/Camera3D/InteractRay
@onready var waterpump_hitbox: Area3D = $Neck/Camera3D/waterpump/waterTank2/waterpump_hitbox
@onready var pump_animation: AnimationPlayer = $Neck/Camera3D/waterpump/pump_animation
@onready var water_tank_barfiller: MeshInstance3D = $Neck/Camera3D/waterpump/waterTank2/waterTankBar/waterTankBarfiller
@onready var pumpwater: AudioStreamPlayer3D = $Neck/Camera3D/waterpump/pumpwater
@onready var freqmeter: Node3D = $Neck/Camera3D/freqmeter
@onready var tronco_1: MeshInstance3D = $Neck/Camera3D/Tronco1
@onready var tronco_2: MeshInstance3D = $Neck/Camera3D/Tronco1/Tronco2
@onready var tronco_3: MeshInstance3D = $Neck/Camera3D/Tronco1/Tronco2/Tronco3




# when the scene is loaded
func _ready() -> void:
	add_to_group("player")
	ServerStore.playerModel = self
	
	# access the PPRootNode from the scene's node tree 
	pp_root_node = get_tree().current_scene.get_node('PPRootNode')
	assert(pp_root_node, "PPRootNode not found") 
	
	# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode");
	if ServerStore.colorR == 0:
		ServerStore.colorR = randf()/4;
		ServerStore.colorG = randf()/4;
		ServerStore.colorB = randf()/4;
	pp_root_node.message({
		"x": ServerStore.posX,
		"y": ServerStore.posY,
		"dimension": "game",
		"color": {
			"r": ServerStore.colorR,
			"g": ServerStore.colorG, 
			"b": ServerStore.colorB
	}});
	
	if pp_entity_node:
		pp_entity_node.state_changed.connect(_on_state_changed)
	else:
		print("PPEntityNode not found")

	pp_entity_node.multiplayer
		
func _on_state_changed(state):
	# sync the player's position, using the server's values
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	var diff_in_position = (global_transform.origin - Vector3(state.x, state.z, -state.y)).abs() 
	if diff_in_position > Vector3(5,5,5):
		global_transform.origin = Vector3(state.x, state.z, -state.y)

	ServerStore.ServerPingNum = state.data.pingnum;
	ServerStore.posX = state.x
	ServerStore.posY = state.y

	ServerStore.colorR = state.data.color.r
	ServerStore.colorG = state.data.color.g
	ServerStore.colorB = state.data.color.b
	#ServerStore.car_posY = state.data.car_posY
	#ServerStore.car_rescue = state.data.car_rescue
	print(str(state.data.win)+" "+str(state.data.game))
	match state.data.win:
		1:
			win()
		2:
			dead("pulpo")
	 
func _server_failed():
	get_tree().change_scene_to_file("res://scenes/main.tscn");
	pass

func _process(delta: float) -> void:

	#if ServerStore._checkPingNum(ServerStore.ServerPingNum):
		#pp_root_node.authenticate_player("","")
		#print("--- forced reautenticate")
		#_server_failed();
	if ServerStore._newPingNumCheck():
		pp_root_node.message({"pingnum": ServerStore.PingNum});
		if ServerStore.lobby_id != "":
			pp_root_node.message({"getLobbyData": ServerStore.lobby_id});
			print("lobbyMessage")
	
	
	
	openmenu()
	woodindicator()
	waterpumphandle()
	axeattack()
	swaptool()
	headbobhandle()
	staminahandle()
	
	move_and_slide()
	if !is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
		
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
	var collide = move_and_collide(movement)
	
	# message the server to update the player's x and y positions
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	if !collide:
		pp_root_node.message({
			"x": movement[0],
			"y": -movement[2], 
			"z": movement[1],
			"rotation":neck.rotation.y
		});

func _physics_process(delta: float) -> void:

	if interact_ray.is_colliding():
		var target = interact_ray.get_collider()
		var test = target.to_string().substr(0,target.to_string().find(":"))
		if target != null and target.has_method("interact"):

			if Input.is_action_just_pressed("interact"):
				var pp_entity_node= get_node_or_null("PPEntityNode");
				if tool_inhand == 2 and test == "calderaagua_detector2":
					player_water = target.interact(player_water)
				elif test == "caldera_detector" and player_wood > 0 and ServerStore.car_fuel < 3:
					player_wood = target.interact(player_wood)
				elif test == "madera_detector":
					player_wood = target.interact(player_wood)

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
			neck.rotate_y(-event.relative.x*Menusettings.mousesen)
			camera.rotate_x(-event.relative.y*Menusettings.mousesen)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

#handles stamina stat and value in bar
func staminahandle():
	if(isRestoring):
		isRestoring = stamina != maxstamina
	if(canRestore and stamina < maxstamina): 
		stamina = stamina + staminarate
	$bar_stamina.value = stamina	
#handles menu in game
func openmenu():
	if Input.is_action_just_pressed("pause_button"):
		if Menusettings.pausemenu_state:
			pause_menu.show()
			print("menu")
		else:
			pause_menu.hide()
			print("nomenu")
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
	if tool_inhand == 1:

		if Input.is_action_just_pressed("attack") and not is_attacking and Menusettings.pausemenu_state and stamina > stamina_attack_cap :
			print(ServerStore.car_posY)
			is_attacking = true
			axe_animation.play("attack_animation")
			axe_hitbox.monitoring = true
			axe_hitbox.set_collision_layer_value(3,true)
			axe_hitbox.set_collision_layer_value(6,true)
			axe_hitbox.set_collision_mask_value(3,true)
			axe_hitbox.set_collision_mask_value(6,true)
			axeswing.pitch_scale = randf_range(.8,1.2)
			axeswing.play()
			stamina = stamina -stamina_attack_cap
			pp_root_node.message({"action": 25});
func _on_axe_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack_animation":
		axe_animation.play("idle_axe_animation")
		axe_hitbox.monitoring = false
		is_attacking=false
		axe_hitbox.set_collision_layer_value(3,false)
		axe_hitbox.set_collision_layer_value(6,false)
		axe_hitbox.set_collision_mask_value(3,false)
		axe_hitbox.set_collision_mask_value(6,false)
func _on_axe_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("arbol") and player_wood <3:
		print("Tree hit")
		player_wood += 1

func woodindicator():
	match player_wood:
		0:
			tronco_1.hide()
			tronco_2.hide()
			tronco_3.hide()
		1:
			tronco_1.show()
			tronco_2.hide()
			tronco_3.hide()
		2:
			tronco_1.show()
			tronco_2.show()
			tronco_3.hide()
		3:
			tronco_1.show()
			tronco_2.show()
			tronco_3.show()

func waterpumphandle():
	if tool_inhand == 2:
		water_tank_barfiller.scale.x = player_water
		if fillingwater_player and player_water <1.0:
			player_water += 0.01
		if Input.is_action_just_pressed("attack"):
			print(ServerStore.is_in_watertank)
			print (player_water > 0.0)
		if Input.is_action_just_pressed("attack") and ServerStore.is_in_watertank and player_water > 0.0:
			is_attacking = true
			waterpump.hide()
			
		if Input.is_action_just_pressed("attack") and Menusettings.pausemenu_state and !ServerStore.is_in_watertank:
			is_attacking = true
			pump_animation.play("use")
			waterpumpsound = true
			waterpump_hitbox.monitoring = true
			speed=1
			pp_root_node.message({"action": 15});

		if Input.is_action_just_released("attack"):
			waterpumpsound = false
			is_attacking=false
			fillingwater_player = false
			waterpump_hitbox.monitoring = false
			pump_animation.stop()
			pumpwater.stop()
			pump_animation.play("idle")
			waterpump.show()
			speed = 20
			
		if waterpumpsound and !pumpwater.playing:
			pumpwater.play()
			
func _on_waterpump_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("pond") and is_attacking:
		print("water pumped")
		fillingwater_player = true
		speed=0.7
		
func _on_waterpump_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("pond") and is_attacking:
		print("water pumped")
		fillingwater_player = true
		speed=0.7
	pass # Replace with function body.
func _on_waterpump_hitbox_area_exited(area: Area3D) -> void:
	if area.is_in_group("pond") and !is_attacking:
		fillingwater_player = false
func _on_waterpump_hitbox_body_exited(body: Node3D) -> void:
	if body.is_in_group("pond") and !is_attacking:
		fillingwater_player = false

#handles tool selection
func swaptool() -> void:
	if Input.is_action_just_pressed("swaptool_up") and tool_inhand < 4 and !is_attacking:
		tool_inhand += 1

		is_attacking=false
		pp_root_node.message({"tool": tool_inhand});
	if Input.is_action_just_pressed("swaptool_down") and tool_inhand > 1:
		tool_inhand -= 1

		is_attacking=false
		pp_root_node.message({"tool": tool_inhand});
	if Input.is_action_just_pressed("1tool"):
		tool_inhand=1
	if Input.is_action_just_pressed("2tool"):
		tool_inhand=2
	if Input.is_action_just_pressed("3tool"):
		tool_inhand=3
	match tool_inhand:
		1:
			axe.show()
			waterpump.hide()
			freqmeter.hide()
		2:
			axe.hide()
			if !(ServerStore.car_filling_water > 0):
				waterpump.show()
			freqmeter.hide()
		3:
			axe.hide()
			waterpump.hide()
			freqmeter.show()


func dead(killer: String):
	ServerStore.playerModel = null
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/gameover.tscn")
	

func win():
	ServerStore.playerModel = null
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/winScreen.tscn")
