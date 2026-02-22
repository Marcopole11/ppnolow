extends Area3D

func interact(playerwater: float):
	if ServerStore.car_water >= 4:
		print("car tank is full")
		return playerwater;
	elif ServerStore.car_water+playerwater > 4:
		var sendwater = ServerStore.car_water+playerwater-4;
		#TODO: Rellena agua - vacia parcialmente el agua del cubo 
		return playerwater - sendwater;
	else:
		#TODO: Rellena agua - vacia toda el agua del cubo
		return 0;
