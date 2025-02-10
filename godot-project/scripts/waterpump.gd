extends Node3D

@onready var player: CharacterBody3D = $"../../.."
@onready var water_tank_barfiller: MeshInstance3D = $waterTank2/waterTankBarfiller
@onready var waterpump: Node3D = $"."
@onready var waterpump_hitbox: Area3D = $waterTank2/waterpump_hitbox



var waterpumpsound:bool
var fillingwater_player:bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	waterpumphandle()
	print(player.player_water)
func waterpumphandle():
	if player.tool_inhand == 2:
		water_tank_barfiller.scale.x = player.player_water
		if fillingwater_player and player.player_water <1.0:
			player.player_water += 0.01
		if Input.is_action_just_pressed("attack") and ServerStore.is_in_watertank and player.player_water > 0.0:
			player.is_attacking = true
			waterpump.hide()
		if Input.is_action_just_pressed("attack") and Menusettings.pausemenu_state and !ServerStore.is_in_watertank:
			player.is_attacking = true
			$pump_animation.play("use")
			waterpumpsound = true
			waterpump_hitbox.monitoring = true
			player.speed=1
			player.pp_root_node.message({"action": 15});
		if Input.is_action_just_released("attack"):
			waterpumpsound = false
			player.is_attacking= false
			fillingwater_player = false
			waterpump_hitbox.monitoring = false
			$pump_animation.stop()
			$pumpwater.stop()
			$pump_animation.play("idle")
			waterpump.show()
			player.speed = 20
		if waterpumpsound and !$pumpwater.playing:
			$pumpwater.play()
func _on_waterpump_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("pond") and player.is_attacking:
		print("water pumped")
		fillingwater_player = true
		player.speed=0.7
func _on_waterpump_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("pond") and player.is_attacking:
		print("water pumped")
		fillingwater_player = true
		player.speed=0.7
	pass # Replace with function body.
func _on_waterpump_hitbox_area_exited(area: Area3D) -> void:
	if area.is_in_group("pond") and !player.is_attacking:
		fillingwater_player = false
func _on_waterpump_hitbox_body_exited(body: Node3D) -> void:
	if body.is_in_group("pond") and !player.is_attacking:
		fillingwater_player = false
