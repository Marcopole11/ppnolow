# entity_movement.gd script

# extend the functionality of your root node (here Node3D)
extends Node3D

@export var playerModel:Node3D;

@export var playerLegs:MeshInstance3D;
@export var playerTorso:MeshInstance3D;
@export var playerGoogles:MeshInstance3D;
@export var playerAnimation:AnimationPlayer;

@export var items:Node3D;

var definedG:float = 0.25;
var newCoth:Material;
var newBright:Material;

var nowplaying:String = "Idle animation";
var tool:int = 1;
var moving:int = 0;


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
	var newOrigin = Vector3(state.x, state.z, -state.y);
	if abs(global_transform.origin.x - newOrigin.x) > 0.1:
		moving = 30;
	if abs(global_transform.origin.z - newOrigin.z) > 0.1:
		moving = 30;
	global_transform.origin = newOrigin;
	var actionActive = state.data.action > 0;
	
	if tool != state.data.tool:
		tool = state.data.tool;
		match tool:
			1:
				items.get_child(0).show()
				items.get_child(1).hide()
				items.get_child(2).hide()
			2:
				items.get_child(0).hide()
				items.get_child(1).show()
				items.get_child(2).hide()
			3:
				items.get_child(0).hide()
				items.get_child(1).hide()
				items.get_child(2).show()
				
	
	if state.data.color.g != definedG:
		definedG = state.data.color.g;
		newCoth.albedo_color = Color(state.data.color.r+0.3,state.data.color.g+0.3,state.data.color.b+0.3,1);
		newBright.albedo_color = Color(state.data.color.r*5,state.data.color.g*5,state.data.color.b*5,1);
	
	var nextplaying = "Idle animation";
	if actionActive and tool == 1:
		nextplaying = "hit";
	elif moving>0:
		if tool > 2 or (actionActive and tool == 2):
			nextplaying = "walkshow";
		else:
			nextplaying = "walking";
	else:
		if tool > 2 or (actionActive and tool == 2):
			nextplaying = "show";
			
	moving-=1;
	if nextplaying != nowplaying:
		playerAnimation.play(nextplaying);
		nowplaying = nextplaying;
