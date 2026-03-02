extends CharacterBody3D

enum Tools {
	AXE,
	WATERPUMP,
	FREQMETER
}

@export_category("Movility")
@export_group("Speed")
@export var speed:float = 35
@export var sprintSpeed:int = 30
var totalSpeed:float = speed
@export_group("Stamina")
@export var stamina:float = 100
@export var maxstamina:float = 100
@export var staminarate:float = 10
var canRestore:bool = true
var isRestoring:bool = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_category("Inventory")
var is_moving:bool = false
@export var tool_inhand:Tools = Tools.AXE
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

@onready var playerInput: MultiplayerSynchronizer = $PlayerInputSynchronizer

var playerPeerId = 1 :
	set(value):
		playerPeerId = value
		$PlayerInputSynchronizer.set_multiplayer_authority(value)


# when the scene is loaded
func _ready() -> void:
	add_to_group("player")
	ServerStore.playerModel = self
	textura_tentaculos.modulate.a = 0
	sonido_ojo.volume_db =-45
	
	if playerPeerId == multiplayer.get_unique_id():
		camera.current = true
	
	# connect to the state_changed signal from pp_entity_node
	if ServerStore.colorR == 0:
		ServerStore.colorR = randf()/4;
		ServerStore.colorG = randf()/4;
		ServerStore.colorB = randf()/4;
		
	#TODO: initilize object on server
		
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
	deathTimer()
	openmenu()
	swaptool()
	headbobhandle()
	# message the server to update the player's x and y positions
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	
	if not playerInput.cameraMovement.is_zero_approx():
		neck.rotate_y(-playerInput.cameraMovement.x * Menusettings.mousesen)
		camera.rotate_x(-playerInput.cameraMovement.y * Menusettings.mousesen)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
		playerInput.cameraMovement = Vector2.ZERO
		
	if hasAxeInHand():
		axe._tool_process(delta)
	elif hasWaterpumpInHand():
		waterpump._tool_process(delta)
	elif hasFreqmeterInHand():
		freqmeter._tool_process(delta)
		
	playerInput.actionAttack = false

func _physics_process(delta: float) -> void:
	staminahandle(delta)
	
	interactor.text= " "
	if interact_ray.is_colliding():
		var target = interact_ray.get_collider()
		var test = target.to_string().substr(0,target.to_string().find(":"))
		if target != null and target.has_method("interact"):
			if playerInput.interact:
				if tool_inhand == Tools.WATERPUMP and test == "calderaagua_detector2":
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
	if playerInput.actionFlash and (flash.has_overlapping_areas() or flash.has_overlapping_bodies()) != null:
		var movement = Vector3(15, 0, 0) * totalSpeed * delta
		
		translate(movement)
	
	# get the raw input values
	var input_direction:Vector3 = playerInput.input_direction
	# calculate the input direction
	input_direction = (neck.transform.basis * Vector3(input_direction.x, 0, input_direction.z)).normalized()

	# move the player
	if(playerInput.sprinting and !isRestoring):
		totalSpeed = speed + sprintSpeed
		stamina -= 10 * delta
		canRestore = false
		isRestoring = stamina <= 0
	else:
		totalSpeed = speed
		canRestore = true

	is_moving = not input_direction.is_zero_approx()
	
	input_direction *= totalSpeed
	input_direction.y = velocity.y
	velocity = input_direction
	move_and_slide()
	gravityCheck(delta)
	playerInput.interact = false
	playerInput.actionFlash = false
	playerInput.actionAttackRelease = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Menusettings.pausemenu_state:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	elif event.is_action_pressed("ui_cancel"):
		if Menusettings.pausemenu_state:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#handles stamina stat and value in bar
func staminahandle(delta):
	if(isRestoring):
		isRestoring = stamina != maxstamina
	if(canRestore and stamina < maxstamina): 
		stamina += staminarate * delta
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
	if playerInput.itemSwap == "" or is_attacking or not Menusettings.pausemenu_state:
		return
	
	match (playerInput.itemSwap):
		"UP":
			if tool_inhand < Tools.size() - 1:
				tool_inhand += 1
		"DOWN":
			if tool_inhand > 0:
				tool_inhand -= 1
		"1":
			tool_inhand = Tools.AXE
		"2":
			tool_inhand = Tools.WATERPUMP
		"3":
			tool_inhand = Tools.FREQMETER
	
	# Tool visibility based on the current tool
	axe.visible = tool_inhand == Tools.AXE
	waterpump.visible = tool_inhand == Tools.WATERPUMP and ServerStore.car_filling_water <= 0
	freqmeter.visible = tool_inhand == Tools.FREQMETER
	
	playerInput.itemSwap = ""

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

func gravityCheck(delta):
	if !is_on_floor():
		velocity.y -= gravity * delta
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

func hasAxeInHand():
	return tool_inhand == Tools.AXE
	
func hasWaterpumpInHand():
	return tool_inhand == Tools.WATERPUMP
	
func hasFreqmeterInHand():
	return tool_inhand == Tools.FREQMETER
