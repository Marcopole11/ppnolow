extends Node3D

@export var playerLegs:MeshInstance3D;
@export var playerTorso:MeshInstance3D;
@export var playerGoogles:MeshInstance3D;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	playerLegs.mesh = playerLegs.mesh.duplicate();
	playerTorso.mesh = playerTorso.mesh.duplicate();
	playerGoogles.mesh = playerGoogles.mesh.duplicate();
	var newCoth:Material = playerLegs.mesh.surface_get_material(0).duplicate();
	var newBright:Material = playerLegs.mesh.surface_get_material(1).duplicate();
	var charColor:Color = Color(randf()/4 , randf()/4, randf()/4, 1);
	newCoth.albedo_color = Color(charColor.r+0.3,charColor.g+0.3,charColor.b+0.3,1);
	newBright.albedo_color = Color(charColor.r*5,charColor.g*5,charColor.b*5,1);
	playerLegs.mesh.surface_set_material(0,newCoth);
	playerTorso.mesh.surface_set_material(1,newBright);
	playerTorso.mesh.surface_set_material(3,newCoth);
	playerGoogles.mesh.surface_set_material(1,newBright);
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
