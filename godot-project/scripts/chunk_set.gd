extends Node3D

var terrainSets = [
	null,
	preload("res://terrains/sets/Set001.tscn"),
	preload("res://terrains/sets/Set002.tscn")
]

var placed = false;

# when the scene is loaded
func _ready():
	# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode")
	# pp_entity_node.new_entity.connect(_on_new_entity)
	
	# print(pp_entity_node.Data);
	
	
func _on_state_changed(state):
	pass


func _on_pp_entity_node_state_changed(new_state):
	if !placed:
		var setnum = new_state.data.set;
		if setnum >= terrainSets.size():
			setnum = 2;
		var terrain:Node3D = terrainSets[setnum].instantiate();
		if new_state.data.side == -1:
			terrain.rotation.y = deg_to_rad(180);
		add_child(terrain);
		placed = true;
