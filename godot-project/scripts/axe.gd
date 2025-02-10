extends Node3D

@onready var tronco_1: MeshInstance3D = $"../Tronco1"
@onready var tronco_2: MeshInstance3D = $"../Tronco1/Tronco2"
@onready var tronco_3: MeshInstance3D = $"../Tronco1/Tronco2/Tronco3"

@onready var player:CharacterBody3D = $"../../.."
@onready var axe_hitbox: Area3D = $MeshInstance3D/axe_hitbox




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	axeattack()
	woodindicator()


func axeattack():
	if player.tool_inhand == 1:
		if Input.is_action_just_pressed("attack") and not player.is_attacking and Menusettings.pausemenu_state and player.stamina > player.stamina_attack_cap :
			print(ServerStore.car_posY)
			player.is_attacking = true
			$axe_animation.play("attack_animation")
			axe_hitbox.monitoring = true
			axe_hitbox.set_collision_layer_value(3,true)
			axe_hitbox.set_collision_layer_value(6,true)
			axe_hitbox.set_collision_mask_value(3,true)
			axe_hitbox.set_collision_mask_value(6,true)
			$axeswing.pitch_scale = randf_range(.8,1.2)
			$axeswing.play()
			player.stamina = player.stamina - player.stamina_attack_cap
			player.pp_root_node.message({"action": 25});
func _on_axe_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack_animation":
		$axe_animation.play("idle_axe_animation")
		axe_hitbox.monitoring = false
		player.is_attacking=false
		axe_hitbox.set_collision_layer_value(3,false)
		axe_hitbox.set_collision_layer_value(6,false)
		axe_hitbox.set_collision_mask_value(3,false)
		axe_hitbox.set_collision_mask_value(6,false)
func _on_axe_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("arbol") and player.player_wood <3:
		print("Tree hit")
		player.player_wood += 1
func woodindicator():
	tronco_1.hide()
	tronco_2.hide()
	tronco_3.hide()
	match player.player_wood:
		1:
			tronco_1.show()
		2:
			tronco_1.show()
			tronco_2.show()
		3:
			tronco_1.show()
			tronco_2.show()
			tronco_3.show()


func _on_waterpump_hitbox_area_entered(area: Area3D) -> void:
	pass # Replace with function body.
