extends Area3D

var pp_root_node
@onready var car_animations: AnimationPlayer = $"../../../Car_animations"
@onready var audiocaldera: AudioStreamPlayer3D = $audiocaldera

func interact(wood: int):
	if wood > 0:
		if ServerStore.car_wood < 15:
			var sobra = wood+ServerStore.car_wood-15
			if sobra<0:
				sobra = 0;
			#TODO: Rellena el stockpile
			return sobra
	elif ServerStore.car_wood > 0:
		var max_wood_allowed = min(ServerStore.car_wood, 3)
		#TODO: Recupera hasta 3 trozos de madera del coche
		return max_wood_allowed
	return 0
	
func sonido():
	audiocaldera.play()
