# entity_movement.gd script

# extend the functionality of your root node (here Node3D)
extends Node3D

var pushForce = 5
# when the scene is loaded
func _ready():
	# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode")
	if pp_entity_node:
		pp_entity_node.state_changed.connect(_on_state_changed)
	else:
		print("PPEntityNode not found")

func _on_state_changed(state):
	# set the entity's position, using the server's values
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	global_transform.origin = Vector3(state.x, state.z, -state.y) 


func _on_interactable_focused(interactor: Interactor) -> void:
	print("focused")


func _on_interactable_interacted(interactor: Interactor, delta: float) -> void:
	var movement = Vector3(0,0,1) * pushForce * delta
	print("moving")
	translate(movement)


func _on_interactable_unfocused(interactor: Interactor) -> void:
	print("unfocused")
