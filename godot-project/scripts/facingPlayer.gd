extends Node3D

var player:Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player == null:
		var playergroup = get_tree().get_nodes_in_group("player");
		if playergroup.size() > 0:
			player = playergroup[0]
	else:
		look_at(player.position+Vector3(0,4,0))
