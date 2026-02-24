extends Node3D
var mapsize_y:int = 16
var mapsize_x:int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if mapsize_y >= 4:
		pass
	else:
		push_error("MAPSIZE TOO SMALL")
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
