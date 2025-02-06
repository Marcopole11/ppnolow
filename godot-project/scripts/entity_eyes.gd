extends Node3D

var player:Node3D = null
@export var eyes:Array[Node3D]
# Called when the node enters the scene tree for the first time.
func _ready():
	
	##player = playergroup[0];
	pass # Replace with function body.
	
func _physics_process(delta):
	if player == null:
		var playergroup = get_tree().get_nodes_in_group("player");
		if playergroup.size() > 0:
			player = playergroup[0]
	else:
		var tall = 3.5;
		for eye in eyes:
			eye.look_at(player.position+Vector3(0,tall,0))
			tall = 4.5;
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
