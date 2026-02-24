# chunk_update.gd script

# extend the functionality of your root node (here Node3D)
extends Node3D

# when the scene is loaded
func _ready():
	# connect to the state_changed signal from pp_chunk_node
	pass

func _on_state_changed(state):
	pass
	# Add code to act if chunk data changes, if necessary
