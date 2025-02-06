# entity_movement.gd script
# extend the functionality of your root node (here Node3D)
extends Node3D
var pp_root_node
@onready var tree_anim: AnimationPlayer = $tree/tree_anim
@onready var tree: Area3D = $tree
var treehp:int = 3
# when the scene is loaded
func _ready():
	# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode")
	if pp_entity_node:
		pp_entity_node.state_changed.connect(_on_state_changed)
	else:
		print("PPEntityNode not found")
	pp_root_node = get_tree().current_scene.get_node('PPRootNode')
	
func _on_state_changed(state):
	# set the entity's position, using the server's values
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	global_transform.origin = Vector3(state.x, state.z, -state.y) 



func _on_tree_area_entered(area: Area3D) -> void:
	if area.is_in_group("axe") and treehp > 0 :
		if treehp > 0:
			tree_anim.play("hit")
			treehp -= 1
		print("Nos pegan :( ",treehp)
		if treehp == 0:
			tree_anim.play("tree_down")
			tree.set_collision_layer_value(2,false)
			pp_root_node.message({"ACABACONMIGO":1})
