# chunk_update.gd script

# extend the functionality of your root node (here Node3D)
extends Node3D

var pp_root_node
# when the scene is loaded
func _ready():
	# connect to the state_changed signal from pp_chunk_node
	var pp_chunk_node= get_node_or_null("PPChunkNode")
	pp_root_node = get_tree().current_scene.get_node_or_null('PPRootNode')
	if pp_chunk_node:
		pp_chunk_node.state_changed.connect(_on_state_changed)
	else:
		print("PPChunkNode not found")

func _on_state_changed(state):
	pass
	# Add code to act if chunk data changes, if necessary
