extends Area3D

@onready var car_animations: AnimationPlayer = $"../../../Car_animations"
@onready var audiocaldera: AudioStreamPlayer3D = $audiocaldera

func interact(fuel: int):
	#Rellena la caldera
	audiocaldera.play()
	car_animations.play("put_wood")
	return fuel - 1
	
func sonido():
	audiocaldera.play()
