extends Node


# no sincronizadas
var is_in_fuel:bool
var is_in_watertank:bool


# output del server (read only)
var car_wood:int = 0;
var car_water:float = 0;
var car_fuel:float = 0;
var car_filling_water:float = 0;
var car_filling_fuel:float = 0;
var car_hot:int = 0;
var car_rescue:String = "safe";
var car_posY:float = 80


# guardado para caida/reconexión
var lobby_id: String = "";
var posX: float = 0;
var posY: float = 0;

var colorR: float = 0;
var colorG: float = 0;
var colorB: float = 0;

var ServerPingNum: int = 0;
var PingNum: int = 0;
var PingNumFails: int = 0;

func _checkPingNum(serverPing:int):
	#print(str(PingNum)+" "+str(serverPing))
	if PingNum > 5+serverPing:
		PingNumFails+=1;
		if PingNumFails == 20:
			return true
	else: 
		PingNumFails=0;
	return false
	
func _newPingNumCheck():
	var newping = Time.get_ticks_msec()/3000;
	var retorno = PingNum != newping;
	PingNum = newping;
	return retorno
