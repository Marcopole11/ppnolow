# entity_movement.gd script
# extend the functionality of your root node (here Node3D)
extends Node3D
var pp_root_node

#var lookX:float = 0
#var lookY:float = 0
# when the scene is loaded
func _ready():
	# connect to the state_changed signal from pp_entity_node
	var pp_entity_node= get_node_or_null("PPEntityNode")
	if pp_entity_node:
		pp_entity_node.state_changed.connect(_on_state_changed)
	else:
		print("PPEntityNode not found")
	
func _on_state_changed(state):
	# set the entity's position, using the server's values
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	global_transform.origin = Vector3(state.x, state.z, -state.y)
	#get_node("lookatme").look_at(Vector3(state.data.lookat.x,4,state.data.lookat.y))
	#hardRot(get_node("lookatme"),Vector3(state.data.lookat.x,4,state.data.lookat.y))
	var theNode:Node3D = get_node("lookatme")
	#look_atan2(theNode.global_transform.origin.x,state.data.lookat.x,theNode.global_transform.origin.z,state.data.lookat.y)
	theNode.look_at(Vector3(state.data.lookat.x,0,state.data.lookat.y) - Vector3(state.x, 0, state.y))

#func rotateToTarget(target, delta):
#	var theNode:Node3D = get_node("lookatme")
#	var direction = (target.global_position - global_position)
#	var angleTo = theNode.transform.x.angle_to(direction)

func look_atan2(x1,x2,y1,y2):
	var rot = atan2(y2-y1, x2-x1)
	print(rad_to_deg(rot))
	(get_node("lookatme")as Node3D).rotation.y = atan2(y2-y1, x2-x1)
	
func hardRot(theNode:Node3D, target:Vector3):
	print(
		str(round(target.x))+" "+
		str(round(theNode.global_transform.origin.x))+" | "+
		str(round(target.z))+" "+
		str(round(theNode.global_transform.origin.z)))
	if target.x > theNode.global_transform.origin.x:
		if target.z > theNode.global_transform.origin.z:
			theNode.rotation.y = deg_to_rad(45);
		else:
			theNode.rotation.y = deg_to_rad(135);
	else:
		if target.z < theNode.global_transform.origin.z:
			theNode.rotation.y = deg_to_rad(225);
		else:
			theNode.rotation.y = deg_to_rad(315);
	
func look_atan(theNode:Node3D, target:Vector3):
	var deltaX = abs(target.x - theNode.global_transform.origin.x);
	var deltaY = abs(target.z - theNode.global_transform.origin.z);
	var rad = 0
	if target.x > theNode.global_transform.origin.x:
		if target.z > theNode.global_transform.origin.z:
			rad = atan2(deltaX, deltaY)
		else:
			rad = deg_to_rad(rad_to_deg(atan2(deltaY, deltaX))+90)
	else:
		if target.z < theNode.global_transform.origin.z:
			rad = deg_to_rad(rad_to_deg(atan2(deltaX, deltaY))+180)
		else:
			rad = deg_to_rad(rad_to_deg(atan2(deltaY, deltaX))+270)
		
	
	theNode.rotation.y = atan2(deltaY, deltaX);
	print(
		str(round(target.x))+" "+
		str(round(theNode.global_transform.origin.x))+" | "+
		str(round(target.z))+" "+
		str(round(theNode.global_transform.origin.z))+" "+
		str(round(rad))+" "+str(round(rad_to_deg(rad))))
	pass
	

func safe_look_at(node : Node3D, target : Vector3) -> void:
	var origin : Vector3 = node.global_transform.origin
	var v_z := (origin - target).normalized()

	# Just return if at same position
	if origin == target:
		return

	# Find an up vector that we can rotate around
	var up := Vector3.ZERO
	for entry in [Vector3.UP, Vector3.RIGHT, Vector3.BACK]:
		var v_x : Vector3 = entry.cross(v_z).normalized()
		if v_x.length() != 0:
			up = entry
			break

	# Look at the target
	if up != Vector3.ZERO:
		node.look_at(target, up)
