extends "res://scripts/entity_movement.gd"

var obstacle: bool = false
var lid_open: bool
@export var car_fuel: int = 0
@export var car_water:int = 0

@onready var animation_tree: AnimationTree = $carro/AnimationTree



var pp_root_node

var pushForce = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pp_root_node = get_tree().current_scene.get_node('PPRootNode')



# Called every frame. 'delta' is the elapsed time since the previous frame.
func interact(delta: float, strength: float):
	var movement = Vector3(0,0,strength) * pushForce * delta
	print("moving")
	translate(movement)
	var current_position = global_transform.origin
	pp_root_node.message({
		"x": current_position[0],
		"y": current_position[1],
		"z": current_position[2],
		"threedee": true
  	})
