extends Node3D

var cardistance:float
var edgemap_distance:int = 350
var freqmetter_step:float
@onready var frequencymetter_indicator:Array[MeshInstance3D]= [
	$frequencymetter/frequencyMetter2/frequencyPoint_001,
	$frequencymetter/frequencyMetter2/frequencyPoint_002,
	$frequencymetter/frequencyMetter2/frequencyPoint_003,
	$frequencymetter/frequencyMetter2/frequencyPoint_004,
	$frequencymetter/frequencyMetter2/frequencyPoint_005,
	$frequencymetter/frequencyMetter2/frequencyPoint_006,
	$frequencymetter/frequencyMetter2/frequencyPoint_007,
	$frequencymetter/frequencyMetter2/frequencyPoint_008,
	]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	freqmetter_step = edgemap_distance/8

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	freq_indicator(frequencymetter_indicator,cardistance)
	cardistance = (sqrt(pow((ServerStore.posY - ServerStore.car_posY),2) +pow((ServerStore.posX - 120),2)))


func freq_indicator(supply:Array[MeshInstance3D],server_value):
	var current_lvl:int = round((edgemap_distance-cardistance)/freqmetter_step)
	if current_lvl < 0:
		current_lvl = 0;
	#print(cardistance," ",current_lvl)
	if current_lvl>supply.size()+1:
		current_lvl=supply.size()+1
	for lvl in range(current_lvl):
		supply[lvl].show()
	for lvl in range(current_lvl-1,supply.size()):
		supply[lvl].hide()
