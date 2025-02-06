extends Area3D

var pp_root_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
			# connect to the state_changed signal from pp_entity_node
	pp_root_node = get_tree().current_scene.get_node('PPRootNode')

func interact(playerwater: float):
	var pp_entity_node=  self.get_parent().get_node_or_null("../../../PPEntityNode")
	var current_position = global_transform.origin
	
	if ServerStore.car_water >= 4:
		print("car tank is full")
		return playerwater;
	elif ServerStore.car_water+playerwater > 4:
		var sendwater = ServerStore.car_water+playerwater-4;
		pp_root_node.message({"ID": pp_entity_node.entity_id,
		"fillWater":sendwater})
		return playerwater - sendwater;
	else:
		pp_root_node.message({"ID": pp_entity_node.entity_id,
		"fillWater":playerwater})
		return 0;
