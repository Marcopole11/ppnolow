# entity_movement.gd script

# extend the functionality of your root node (here Node3D)
extends StaticBody3D

var en_caldera:bool = false

var car_is_on:bool
var obstacle: bool = false
var lid_open: bool
var lid_selected:bool = false
var car_water_indicator:int = 0
@onready var caldera_detector: Area3D = $Node3D/carro/carro/caldera_detector
@onready var calderaagua_detector_2: Area3D = $Node3D/carro/carro/calderaagua_detector2
@onready var waterlvl_001: MeshInstance3D = $Node3D/carro/waterlvl_001
@onready var waterlvl_002: MeshInstance3D = $Node3D/carro/waterlvl_002
@onready var waterlvl_003: MeshInstance3D = $Node3D/carro/waterlvl_003
@onready var waterlvl_004: MeshInstance3D = $Node3D/carro/waterlvl_004
@onready var car_animations: AnimationPlayer = $Node3D/AnimationTree/Car_animations
@onready var car_animtree: AnimationTree = $Node3D/car_animtree


var player = null
var distance:float
var pp_root_node
var pushForce = 5

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
	
	

func _process(delta: float) -> void:
	watertank_car_indicator()
	fill_car_watertank()
	if ServerStore.car_water > 0 and ServerStore.car_fuel > 0:
		interact(delta,0)
		car_animations.play("shake")
	

func fill_car_watertank():
	if ServerStore.car_isfilling:
		ServerStore.car_water += 0.11
		print("llenandocoche ",ServerStore.car_water)
	if ServerStore.car_water > 4.00:
		ServerStore.car_isfilling = false
		
func watertank_car_indicator():
	car_water_indicator = round(ServerStore.car_water)
	match car_water_indicator:
		0:
			waterlvl_001.hide()
			waterlvl_002.hide()
			waterlvl_003.hide()
			waterlvl_004.hide()
		1:
			waterlvl_001.show()
			waterlvl_002.hide()
			waterlvl_003.hide()
			waterlvl_004.hide()
		2:
			waterlvl_001.show()
			waterlvl_002.show()
			waterlvl_003.hide()
			waterlvl_004.hide()
		3:
			waterlvl_001.show()
			waterlvl_002.show()
			waterlvl_003.show()
			waterlvl_004.hide()
		4:
			waterlvl_001.show()
			waterlvl_002.show()
			waterlvl_003.show()
			waterlvl_004.show()

	if player == null:
		var checkarraysize = get_tree().get_nodes_in_group("player") if get_tree() else []
		if checkarraysize.size() > 0:
			player = checkarraysize[0]
	if player != null:
		Menusettings.distance = global_position.distance_to(player.global_position)
	
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
	var diff_in_position = (global_transform.origin - Vector3(state.x, state.z, -state.y)).abs() 
	if diff_in_position > Vector3(1,1,1):
		global_transform.origin = Vector3(state.x, state.z, -state.y)

func _on_calderaagua_detector_2_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("caldera de agua")
		ServerStore.is_in_watertank = true
func _on_caldera_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("caldera")
		ServerStore.is_in_fuel = true

func _on_caldera_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("fuera caldera")
		ServerStore.is_in_fuel = false
func _on_calderaagua_detector_2_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("fuera caldera de agua")
		ServerStore.is_in_watertank = false
