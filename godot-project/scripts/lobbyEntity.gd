extends Node3D


var placed = false;

# when the scene is loaded
func _ready():
	# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode")
	# pp_entity_node.new_entity.connect(_on_new_entity)
	
	# print(pp_entity_node.Data);
	
	
func _on_state_changed(state):
	pass

func _on_pp_entity_node_2_state_changed(new_state):
	if !placed:
		var setnum = new_state.data.set;
		if new_state.x < 0:
			terrain.rotation.y = deg_to_rad(180);
		add_child(terrain);
		placed = true;
	pass # Replace with function body.
