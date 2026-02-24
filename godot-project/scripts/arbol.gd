extends StaticBody3D


var treehp:int = 3

@onready var tree_anim: AnimationPlayer = $tree_anim

func _on_state_changed(state):
	# set the entity's position, using the server's values
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	global_transform.origin = Vector3(state.x, state.z, -state.y) 
	#ID = state.data.id
	
func _on_tree_area_entered(area: Area3D) -> void:
	if area.is_in_group("axe") and treehp > 0 :
		if treehp > 0:
			tree_anim.play("hit")
			treehp -= 1
		print("Nos pegan :( ",treehp)
		if treehp == 0:
			tree_anim.play("tree_down")
			self.visible = false
			queue_free()
