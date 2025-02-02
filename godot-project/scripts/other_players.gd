# entity_movement.gd script

# extend the functionality of your root node (here Node3D)
extends Node3D

@export var playerModel:Node3D;

@export var playerLegs:MeshInstance3D;
@export var playerTorso:MeshInstance3D;
@export var playerGoogles:MeshInstance3D;

var definedG:float = 0.25;
var newCoth:Material;
var newBright:Material;

# when the scene is loaded
func _ready():
	# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode")
	if pp_entity_node:
		pp_entity_node.state_changed.connect(_on_state_changed)
	else:
		print("PPEntityNode not found")
		
	playerLegs.mesh = playerLegs.mesh.duplicate();
	playerTorso.mesh = playerTorso.mesh.duplicate();
	playerGoogles.mesh = playerGoogles.mesh.duplicate();
	newCoth = playerLegs.mesh.surface_get_material(0).duplicate();
	newBright = playerLegs.mesh.surface_get_material(1).duplicate();
	playerLegs.mesh.surface_set_material(0,newCoth);
	playerTorso.mesh.surface_set_material(1,newBright);
	playerTorso.mesh.surface_set_material(3,newCoth);
	playerGoogles.mesh.surface_set_material(1,newBright);

func _on_state_changed(state):
	# set the entity's position, using the server's values
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	# print(state.data.color);
	playerModel.rotation.y = state.data.rotation;
	global_transform.origin = Vector3(state.x, state.z, -state.y);
	
	if state.data.color.g != definedG:
		definedG = state.data.color.g;
		newCoth.albedo_color = Color(state.data.color.r+0.3,state.data.color.g+0.3,state.data.color.b+0.3,1);
		newBright.albedo_color = Color(state.data.color.r*5,state.data.color.g*5,state.data.color.b*5,1);
