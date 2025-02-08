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
		var tall = 4;
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
	var speed = (abs((org-deg)/4)+1)/5
	if org == deg:
		return rad
	if org < deg:
		if org+speed > deg: return deg_to_rad(deg)
		else: return deg_to_rad(org+speed)
	else:
		if org-speed < deg: return deg_to_rad(deg)
		else: return deg_to_rad(org-speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frame=frame+1
	if frame > 30:
		frame = 0
		var spotted = 0;
		for eye in range(eyes.size()):
			eyesJobY[eye] = randomSpot(eyesJobY[eye])
			eyesJobZ[eye] = randomSpot(eyesJobZ[eye])
			if eyesJobY[eye] == 90 and eyesJobZ[eye] == 90:
				spotted = spotted + 1
		if spotted > 3:
			eyesJobY[0] = 90
			eyesJobZ[0] = 90

func randomSpot(old:int):
	var rot = randi_range(-1400,400)
	if rot<0:
		return old
	if rot>180:
		return 90
	return rot
	


func _on_atk_area_body_entered(target: Node3D) -> void:
	if target.has_method("dead"):
		target.dead("Eyes")
