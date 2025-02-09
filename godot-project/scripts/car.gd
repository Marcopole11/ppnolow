# entity_movement.gd script

# extend the functionality of your root node (here Node3D)
extends StaticBody3D

var obstacle: bool = false
var calderaMaterial:Material
var player = null
var pp_root_node
var pushForce:float = 5

#variables del pulpo
var Pulpohp = 3
var pulpoaway:bool =false
@onready var caldera_detector: Area3D = $Node3D/carro/carro/caldera_detector
@onready var calderaagua_detector_2: Area3D = $Node3D/carro/carro/calderaagua_detector2


@onready var car_animations: AnimationPlayer = $Node3D/Car_animations
@onready var watertank_car_mesh: MeshInstance3D = $Node3D/carro/carro/waterTank2
@onready var rueda_br: MeshInstance3D = $Node3D/carro/Rueda_BR_001
@onready var rueda_bl: MeshInstance3D = $Node3D/carro/Rueda_BL
@onready var rueda_tr: MeshInstance3D = $Node3D/carro/Rueda_TR
@onready var rueda_tl: MeshInstance3D = $Node3D/carro/Rueda_TL
@onready var gpu_particles_3d_1: GPUParticles3D = $Node3D/carro/carro/GPUParticles3D2
@onready var gpu_particles_3d_2: GPUParticles3D = $Node3D/carro/carro/GPUParticles3D3
@onready var carroMesh: MeshInstance3D = $Node3D/carro/carro
@onready var calderalight:OmniLight3D = $Node3D/carro/carro/caldera/luzCaldera
@onready var calderaFire:GPUParticles3D = $Node3D/carro/carro/caldera/fuegoCaldera
@onready var waterlvl:Array[MeshInstance3D] = [
	$Node3D/carro/waterlvl_001,
	$Node3D/carro/waterlvl_002,
	$Node3D/carro/waterlvl_003,
	$Node3D/carro/waterlvl_004]
@onready var woodPile:Array[MeshInstance3D] = [
	$Node3D/carro/carro/wood,
	$Node3D/carro/carro/wood/wood2,
	$Node3D/carro/carro/wood/wood3,
	$Node3D/carro/carro/wood/wood4,
	$Node3D/carro/carro/wood/wood5,
	$Node3D/carro/carro/wood/wood6,
	$Node3D/carro/carro/wood/wood7,
	$Node3D/carro/carro/wood/wood8,
	$Node3D/carro/carro/wood/wood9,
	$Node3D/carro/carro/wood/wood10,
	$Node3D/carro/carro/wood/wood11,
	$Node3D/carro/carro/wood/wood12,
	$Node3D/carro/carro/wood/wood13,
	$Node3D/carro/carro/wood/wood14,
	$Node3D/carro/carro/wood/wood15]
@onready var fuelPile:Array[MeshInstance3D] = [
	$Node3D/carro/carro/fuel,
	$Node3D/carro/carro/fuel/fuel2,
	$Node3D/carro/carro/fuel/fuel3]
@onready var pulpo_animations: AnimationPlayer = $Node3D/carro/carro/Area3D/Pulpo/Pulpo_animations



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode")
	if pp_entity_node:
		var test = pp_entity_node.get_property_list()
		pp_entity_node.state_changed.connect(_on_state_changed)
	else:
		print("PPEntityNode not found")
	pp_root_node = get_tree().current_scene.get_node('PPRootNode')
	calderaMaterial=carroMesh.mesh.surface_get_material(4).duplicate()
	carroMesh.mesh.surface_set_material(4,calderaMaterial)
	calderaMaterial.set("emission_energy_multiplier",0)
	
func _process(delta: float) -> void:
	supply_indicator(waterlvl,ServerStore.car_water)
	supply_indicator(woodPile,ServerStore.car_wood)
	if ServerStore.car_hot > 20:
		interact(delta,0)
		car_animations.play("car_shake")
		gpu_particles_3d_1.show()
		gpu_particles_3d_2.show()
		spinwheel(ServerStore.car_hot,4150)
	if ServerStore.car_hot < 20:
		gpu_particles_3d_1.hide()
		gpu_particles_3d_2.hide()
	calderaMaterial.set("emission_energy_multiplier",(ServerStore.car_hot as float)/100)
	calderalight.set("light_energy",(ServerStore.car_hot as float)/40)
	if ServerStore.car_fuel>0:
		calderaFire.emitting = ServerStore.car_hot/8
		supply_indicator(fuelPile,ServerStore.car_fuel+1)
	else:
		calderaFire.emitting = 0
		supply_indicator(fuelPile,0)
	pulpoattack()
	
	var pp_entity_node= get_node_or_null("PPEntityNode")
	if Input.is_key_pressed(KEY_7):
		print("all win")
		pp_root_node.message({"ID": pp_entity_node.entity_id,
			"gameEnd": true,"gFinale":"t"})
	if Input.is_key_pressed(KEY_8):
		print("all loose")
		pp_root_node.message({"ID": pp_entity_node.entity_id,
			"gameEnd": false,"gFinale":"t"})
	
	
func supply_indicator(supply:Array[MeshInstance3D],server_value):
	var current_lvl = round(server_value)
	if current_lvl>supply.size()+1:
		current_lvl=supply.size()+1
	for lvl in range(current_lvl):
		supply[lvl-1].show()
	for lvl in range(current_lvl-1,supply.size()):
		supply[lvl].hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func interact(delta: float, strength: float):
	var movement = Vector3(0,0,strength) * pushForce * delta
	translate(movement)
	var pp_entity_node= get_node_or_null("PPEntityNode")
	var current_position = global_transform.origin
	pp_root_node.message({"ID": pp_entity_node.entity_id,
	"move":{
		"x": current_position[0],
		"y": current_position[1],
		"z": 0 - current_position[2],
  	}})

func _on_state_changed(state):
	# set the entity's position, using the server's valuesw
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	##var diff_in_position = (global_transform.origin - Vector3(state.x, state.z, -state.y)).abs() 
	##if diff_in_position > Vector3(1,1,1):
	#print(state)
	
	global_transform.origin = Vector3(state.x, state.z, -state.y)
	ServerStore.car_wood = state.data.wood;
	ServerStore.car_water = state.data.water;
	ServerStore.car_fuel = state.data.fuel;
	ServerStore.car_filling_water = state.data.filling.water > 0;
	ServerStore.car_filling_water = state.data.filling.fuel > 0;
	ServerStore.car_hot = state.data.hot;
	ServerStore.lobby_id = state.data.lobby;
	ServerStore.car_rescue = state.data.rescue;


func spinwheel(speed:float,divspeed):
	rueda_bl.rotate_x(speed/divspeed)
	rueda_br.rotate_x(speed/divspeed)
	rueda_tl.rotate_x(speed/divspeed)
	rueda_tr.rotate_x(speed/divspeed)
	
func pulpoattack():
	if ServerStore.car_rescue == "safe" and !pulpoaway:
		pulpo_animations.play("fly away")
		car_animations.play("drop")
		pulpoaway = true
		pass
	if ServerStore.car_rescue != "safe" and pulpoaway:
		pulpo_animations.play("wings")
		car_animations.play("fly")
		pulpoaway = false

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("axe"):
		pass


		
		
		
