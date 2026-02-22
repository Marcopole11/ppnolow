extends Node3D

var terrainSets = [
	preload("res://terrains/sets/Set000.tscn"),
	preload("res://terrains/sets/Set001.tscn"),
	preload("res://terrains/sets/Set002.tscn"),
	preload("res://terrains/sets/Set003.tscn"),
	preload("res://terrains/sets/Set004.tscn"),
	preload("res://terrains/sets/Set005.tscn"),
	preload("res://terrains/sets/Set006.tscn"),
	preload("res://terrains/sets/Set007.tscn"),
	preload("res://terrains/sets/Set008.tscn"),
	preload("res://terrains/sets/Set009.tscn"),
	preload("res://terrains/sets/Set010.tscn")
]

var placed = false;

func _on_pp_entity_node_state_changed(new_state):
	if !placed:
		for x in 3:
			for y in 3:
				var setnum = new_state.data.sets["r"+str(x)]["r"+str(y)];
				if setnum >= terrainSets.size():
					setnum = 2;
				if setnum > 1 and new_state.y > 0:
					setnum = 2;
				var terrain:Node3D = terrainSets[setnum].instantiate();
				if new_state.x < 30:
					terrain.rotation.y = deg_to_rad(180);
				elif new_state.x < 60 and x == 0:
					terrain.rotation.y = deg_to_rad(180);
				add_child(terrain);
				terrain.position.x = x*80;
				terrain.position.z = y*80;
		placed = true;
