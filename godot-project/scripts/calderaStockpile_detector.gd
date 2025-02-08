extends Area3D

var pp_root_node
@onready var car_animations: AnimationPlayer = $"../../../Car_animations"
@onready var audiocaldera: AudioStreamPlayer3D = $audiocaldera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect to the state_changed signal from pp_entity_node
	pp_root_node = get_tree().current_scene.get_node('PPRootNode')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact(wood: int):
	var pp_entity_node= get_node_or_null("../../../../PPEntityNode")
	if wood > 0:
		if ServerStore.car_wood < 15:
			var sobra = wood+ServerStore.car_wood-15
			if sobra<0:
				sobra = 0;
			pp_root_node.message({"ID": pp_entity_node.entity_id,
			"fillWood": wood-sobra})
			return sobra
	elif ServerStore.car_wood > 3:
		pp_root_node.message({"ID": pp_entity_node.entity_id,
		"getWood": 3})
		return 3
	elif ServerStore.car_wood > 0:
		var gotWood = ServerStore.car_wood
		pp_root_node.message({"ID": pp_entity_node.entity_id,
		"getWood": ServerStore.car_wood})
		return gotWood
	return 0
	
func sonido():
	audiocaldera.play()
