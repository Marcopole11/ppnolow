# entity_movement.gd script

# extend the functionality of your root node (here Node3D)
extends Area3D


var obstacle: bool = false
var lid_open: bool = false
@export var car_fuel: int = 0
@export var car_water:int = 0
 


var pp_root_node

var pushForce = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode")
	if pp_entity_node:
		pp_entity_node.state_changed.connect(_on_state_changed)
	else:
		print("PPEntityNode not found")
	pp_root_node = get_tree().current_scene.get_node('PPRootNode')

func _process(delta: float) -> void:
	var current_position = global_transform.origin
	pp_root_node.message({"move":{
		"ID": "entityID",
		"x": current_position[0],
		"y": current_position[1],
		"z": current_position[2],
  	}})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func interact(delta: float, strength: float):
	var entity_node = self.get_node_or_null('PPEntityNode')
	var test = entity_node.get_me
	var movement = Vector3(0,0,strength) * pushForce * delta
	print("moving")
	translate(movement)

func _on_state_changed(state):
	# set the entity's position, using the server's values
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	global_transform.origin = Vector3(state.x, state.z, -state.y) 
