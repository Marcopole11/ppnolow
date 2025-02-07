extends Node3D

var player:Node3D = null
@export var eyes:Array[Node3D]
# Called when the node enters the scene tree for the first time.

var frame = 0;
var eyesJobY:Array[int]
var eyesJobZ:Array[int]

func _ready():
	for eye in range(eyes.size()):
		eyesJobY.append(90);
		eyesJobZ.append(90);
	##player = playergroup[0];
	pass # Replace with function body.
	
func _physics_process(delta):
	if player == null:
		var playergroup = get_tree().get_nodes_in_group("player");
		if playergroup.size() > 0:
			player = playergroup[0]
	else:
		var tall = 3.5;
		for eye in range(eyes.size()):
			eyes[eye].look_at(player.position+Vector3(0,tall,0))
			var eyemesh:Node3D = eyes[eye].get_node("EyeMesh")
			eyemesh.rotation = Vector3(rad_to_deg(0),
				babyStep(eyemesh.rotation.y,eyesJobY[eye]),
				babyStep(eyemesh.rotation.z,eyesJobZ[eye]));
			tall = 4.5;
	pass

	
func babyStep(rad:float,deg:int):
	var org = rad_to_deg(rad)
	var retorno = deg
	if org == deg:
		return rad
	if org < deg:
		if org+2 > deg: return deg_to_rad(deg)
		else: return deg_to_rad(org+2)
	else:
		if org-2 < deg: return deg_to_rad(deg)
		else: return deg_to_rad(org-2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frame=frame+1
	if frame > 5000:
		frame = 0
		for eye in range(eyes.size()):
			eyesJobY[eye] = 0;
			eyesJobZ[eye] = 0;
