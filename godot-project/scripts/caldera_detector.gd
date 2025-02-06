extends Area3D

var pp_root_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect to the state_changed signal from pp_entity_node
	pp_root_node = get_tree().current_scene.get_node('PPRootNode')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact(fuel: int):
	var pp_entity_node= get_node_or_null("../../../../PPEntityNode")
	var current_position = global_transform.origin
	pp_root_node.message({"ID": pp_entity_node.entity_id,
	"fuel": fuel})
	return fuel - 1
