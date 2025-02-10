extends CharacterBody3D

var pp_root_node
@export_category("Movility")
@export_group("Speed")
@export var speed:float = 35
@export var sprintSpeed:int = 30
var totalSpeed:int = speed	
@export_group("Stamina")
@export var stamina:float = 100
@export var maxstamina:float = 100
@export var staminarate:float = 0.5
var canRestore:bool = true
var isRestoring:bool = false

var gravity = 1

@export_category("Inventory")
var is_moving:bool = false
@export var tool_inhand:int = 1
var is_attacking : bool = false
var stamina_attack_cap:int = 35

@export_group("Wood")
@export var player_wood:int = 0
@export_group("Water")
@export var player_water:float = 0


@export_category("Death conditions")
@export_group("Stalker")
@export var edgemap_distance:int = 240
@export_group("Eye")
@export var timerDeath:int = 0
@export var watchingDeath:bool = false



@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var headbob: AnimationPlayer = $Neck/headbob
@onready var pause_menu: Control = $pause_menu
@onready var bar_stamina: TextureProgressBar = $bar_stamina
@onready var axe: Node3D = $Neck/Camera3D/Axe
@onready var waterpump: Node3D = $Neck/Camera3D/waterpump
@onready var sonido_ojo: AudioStreamPlayer3D = $Sonido_ojo
@onready var interact_ray: RayCast3D = $Neck/Camera3D/InteractRay
@onready var enemy_ray: RayCast3D = $Neck/Camera3D/Enemydetector
@onready var freqmeter: Node3D = $Neck/Camera3D/freqmeter
@onready var textura_tentaculos: TextureRect = $Neck/Camera3D/CanvasLayer/Textura_tentaculos
@onready var interactor: Label = $Interactor
@onready var flash: Area3D = $Flash
@onready var canvas_layer: CanvasLayer = $Neck/Camera3D/CanvasLayer




# when the scene is loaded
func _ready() -> void:
	add_to_group("player")
	ServerStore.playerModel = self
	textura_tentaculos.modulate.a = 0
	sonido_ojo.volume_db =-45
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
	
	## OPTIMIZADO: UTILIZA LERP (INTERPOLACION DE POSICION) EN LUGAR DE HACER TP A LA POSICION ESPECIFICA TUTORIAL MAMALON https://www.youtube.com/watch?v=w2p0ugw3afs
	# sync the player's position, using the server's values
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	var server_position = Vector3(state.x, state.z, -state.y)
	if global_transform.origin.distance_to(server_position) > 5:
		global_transform.origin = global_transform.origin.lerp(server_position, 0.1)

	ServerStore.ServerPingNum = state.data.pingnum;
	ServerStore.posX = state.x
	ServerStore.posY = state.y

	ServerStore.colorR = state.data.color.r
	ServerStore.colorG = state.data.color.g
	ServerStore.colorB = state.data.color.b
	#ServerStore.car_posY = state.data.car_posY
	#ServerStore.car_rescue = state.data.car_rescue
	#print(str(state.data.win)+" "+str(state.data.game))
	match state.data.win:
		1:
			win()
		2:
			dead("pulpo")
	 
func _server_failed():
	get_tree().change_scene_to_file("res://scenes/main.tscn");
	pass

func _process(delta: float) -> void:
	pingCheck()
	deathTimer()
	openmenu()
	swaptool()
	headbobhandle()
	staminahandle()
	move_and_slide()
	gravityCheck(delta)
	
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
	interactor.text= " "
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
					
			if test == "calderaagua_detector2":
				interactor.text= "Press E to add water"
			if test == "caldera_detector":
				interactor.text= "Press E to add wood"
			if test == "madera_detector":
				interactor.text= "Press E to add wood"
				
	if enemy_ray.is_colliding():
		var target = enemy_ray.get_collider()
		if target:
			var area = target.to_string().substr(0,target.to_string().find(":"))
			if area == "AtkArea":
				watchingDeath = true
				if timerDeath > 500:
					dead("Eyes")
	else:
		watchingDeath = false
	if Input.is_action_just_pressed("flash") and (flash.has_overlapping_areas() or flash.has_overlapping_bodies()) != null:
		var movement = Vector3(15, 0, 0) * totalSpeed * delta
		
		translate(movement)
		
		pp_root_node.message({
			"x": movement[0],
			"y": -movement[2], 
			"z": 0,
			"rotation":neck.rotation.y
		});
		

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

##OPTIMIZADO: CAMBIA LA FUNCION CON ELIF PARA NO COMPROBAR 4 VECES LA MISMA COSA JIJIJI + AHORA NO PUEDES CAMBIAR EN EL MENU
#handles tool selection 
func swaptool() -> void:
	var action_pressed = false
	var new_tool = tool_inhand
	if Input.is_action_just_pressed("swaptool_up") and tool_inhand < 3 and !is_attacking and Menusettings.pausemenu_state:
		new_tool += 1
		action_pressed = true
	elif Input.is_action_just_pressed("swaptool_down") and tool_inhand > 1 and Menusettings.pausemenu_state:
		new_tool -= 1
		action_pressed = true
	elif Input.is_action_just_pressed("1tool") and Menusettings.pausemenu_state:
		new_tool = 1
		action_pressed = true
	elif Input.is_action_just_pressed("2tool") and Menusettings.pausemenu_state:
		new_tool = 2
		action_pressed = true
	elif Input.is_action_just_pressed("3tool") and Menusettings.pausemenu_state:
		new_tool = 3
		action_pressed = true
	if action_pressed:
		tool_inhand = new_tool
		is_attacking = false


	# Tool visibility based on the current tool
	axe.visible = tool_inhand == 1
	waterpump.visible = tool_inhand == 2 and ServerStore.car_filling_water <= 0
	freqmeter.visible = tool_inhand == 3

func deathTimer():
	if watchingDeath:
		canvas_layer.show()
		timerDeath += 1
		if sonido_ojo.volume_db < 25:
			sonido_ojo.volume_db +=0.1
	if !watchingDeath and timerDeath > 0:
		canvas_layer.hide()
		timerDeath -= 1
		if sonido_ojo.volume_db > -40:
			sonido_ojo.volume_db -=1
	textura_tentaculos.modulate.a = (timerDeath/100)*0.5

func pingCheck():
	if ServerStore._newPingNumCheck():
		pp_root_node.message({"pingnum": ServerStore.PingNum});
		if ServerStore.lobby_id != "":
			pp_root_node.message({"getLobbyData": ServerStore.lobby_id});
			print("lobbyMessage")

func gravityCheck(x):
	if !is_on_floor():
		velocity.y -= gravity * x
	else:
		velocity.y = 0

func dead(killer: String):
	ServerStore.playerModel = null
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/gameover.tscn")

func win():
	ServerStore.playerModel = null
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/winScreen.tscn")
