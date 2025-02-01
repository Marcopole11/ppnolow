extends Node3D

@export var playerLegs:MeshInstance3D;
@export var playerTorso:MeshInstance3D;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	playerLegs.mesh = playerLegs.mesh.duplicate();
	var newCoth:Material = playerLegs.mesh.surface_get_material(0).duplicate();
	newCoth.albedo_color = Color(randf() , randf(), randf(), 1);
	playerLegs.mesh.surface_set_material(0,newCoth);
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
