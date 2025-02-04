extends Node

var lobby_id: int

var posX: float = 0;
var posY: float = 0;

var colorR: float = 0;
var colorG: float = 0;
var colorB: float = 0;

var PingNum: int = 0;
var PingNumFails: int = 0;

func _checkPingNum(serverPing:int):
	if PingNum != serverPing:
		PingNumFails+=1;
		if PingNumFails == 20:
			return true
	else: 
		PingNumFails=0;
	return false
	
func _newPingNumCheck():
	var newping = Time.get_ticks_msec()/3000;
	var retorno = PingNum == newping;
	PingNum = newping;
	return retorno
