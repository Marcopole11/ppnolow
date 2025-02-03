# entity_movement.gd script

# extend the functionality of your root node (here Node3D)
extends Area3D

var obstacle: bool = false
var lid_open: bool
var lid_selected:bool = false
@export var car_fuel: int = 0
@export var car_water:int = 0

@onready var animation_tree: AnimationTree = $carro/AnimationTree
@onready var outline: MeshInstance3D = $carro/Cube_001/Cube_001
@onready var cube_001: MeshInstance3D = $carro/Cube_001

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
	global_transform.origin = Vector3(state.x, state.z, -state.y);
