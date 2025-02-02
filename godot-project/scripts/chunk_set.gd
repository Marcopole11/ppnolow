extends Node3D

var terrainSets = [
	null,
	preload("res://terrains/sets/Set001.tscn"),
	preload("res://terrains/sets/Set002.tscn")
]

var placed:bool = false;

# when the scene is loaded
func _ready():
	# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode")

func _on_state_changed(state):
	if !placed and state.set != 0:
		placed=true;
		var setnum = state.set;
		if setnum >= terrainSets.size():
			setnum = 2;
		var terrain:Node3D = terrainSets[setnum].instantiate();
		if state.side == -1:
			terrain.rotation.y = deg_to_rad(180);
		add_child(terrain);
