# root.gd script

# extend the functionality of your root node (here Node3D)
extends Node3D

# create a variable to store the PPRootNode
var pp_root_node

# preload all the scenes for use by this script
var player_scene = preload("res://scenes/player.tscn")

var tst_scene = preload("res://scenes/tst.tscn")
var tree_scene = preload("res://scenes/tree.tscn")
var car_scene = preload("res://scenes/car.tscn")
var other_player_scene = preload("res://scenes/player_2.tscn")
var lobby_scene = preload("res://scenes/lobby.tscn")


var chunk_scene = preload("res://scenes/chunk.tscn")
var chunk_set_scene = preload("res://scenes/ChunkSet.tscn")

# define all the scenes by their entity type, except the player character
var scene_map = {
	"tst": tst_scene,
	"tree": tree_scene,
	"car": car_scene,
	"player": other_player_scene,
	"chunkset": chunk_set_scene,
	"lobby": lobby_scene
}

# when the scene is loaded
func _ready():
	# access the PPRootNode from the scene's node tree
	pp_root_node = get_tree().current_scene.get_node_or_null('PPRootNode')
	assert(pp_root_node, "PPRootNode not found") 

	# using signals from the PPRootNode,
	# trigger functions for entity spawning/despawning/positioning 
	pp_root_node.new_player_entity.connect(_on_new_player_entity)
	pp_root_node.new_entity.connect(_on_new_entity)
	pp_root_node.remove_entity.connect(_on_remove_entity)
	
	pp_root_node.new_chunk.connect(_on_new_chunk)
	pp_root_node.remove_chunk.connect(_on_remove_chunk)
	
	pp_root_node.authenticate_player("","")
	

# create a new player instance, and add it as a child node
func _on_new_player_entity(entity_id, state):
	#check if the player instance already exists, and exit function if so  
	for instance in get_children():
		var pp_entity = instance.get_node_or_null('PPEntityNode')
		if pp_entity and "entity_id" in pp_entity:
			if pp_entity.entity_id == entity_id:
				return
				
	# create the player instance
	var player_instance = player_scene.instantiate()

	# validate that the player scene has a PPEntityNode
	var pp_entity_node = player_instance.get_node_or_null("PPEntityNode")
	if pp_entity_node:
		pp_entity_node.entity_id = entity_id
	else:
		print("PPEntityNode not found in the player instance")

	# add the player as a child of the root node
	add_child(player_instance)
	# position the player based on its server location
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	player_instance.global_transform.origin = Vector3(state.x, state.z, -state.y)

# create an entity instance matching its type, and add it as a child node
func _on_new_entity(entity_id, state):
	# get the entity scene based on entity type
	var entity_scene = scene_map.get(state.type)
	# validate that the entity type has a matching scene
	if not entity_scene:
		print("matching scene not found: " + state.type)

	# create an entity instance
	var entity_instance = entity_scene.instantiate()

	# validate that the entity scene has a PPEntityNode
	var pp_entity_node = entity_instance.get_node_or_null("PPEntityNode")
	if pp_entity_node:
		pp_entity_node.entity_id = entity_id
	else:
		print("PPEntityNode not found in the instance")

	# add the entity as a child of the root node  
	add_child(entity_instance)
	# position the entity based on its server location
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	entity_instance.global_transform.origin = Vector3(state.x, state.z, -state.y)

# remove an entity instance, from the current child nodes
func _on_remove_entity(entity_id):
	for child in get_children():
		# check if the child is an entity 
		var pp_entity_node = child.get_node_or_null("PPEntityNode")

		# check if it matches the entity_id to be removed
		if pp_entity_node and pp_entity_node.entity_id == entity_id:
			# delink the child from the parent
			remove_child(child)
			# remove the child from processing
			child.queue_free()
			print('Entity ' + entity_id + ' removed')
			return
	  
	print('Entity ' + entity_id + ' not found to remove')

#create an chunk instance matching its type, and add it as a child node
func _on_new_chunk(chunk_id, state):
	if not chunk_scene:
		print("matching scene not found: chunk_scene" )

	# create an chunk instance
	var chunk_instance = chunk_scene.instantiate()

	# validate that the entity scene has a PPEntityNode
	var pp_chunk_node = chunk_instance.get_node_or_null("PPChunkNode")
	if pp_chunk_node:
		pp_chunk_node.chunk_id = chunk_id
	else:
		print("PPChunkNode not found in the instance")

	# add the chunk as a child of the root node  
	add_child(chunk_instance)
	# position the entity based on its server location
	# NOTE: Planetary Processing uses 'y' for depth in 3D games, and 'z' for height. The depth axis is also inverted.
	# To convert, set Godot's 'y' to negative, then swap 'y' and 'z'.
	chunk_instance.global_transform.origin = Vector3((state.x * pp_root_node.Chunk_Size), 0, -(state.y *  pp_root_node.Chunk_Size))

# remove an chunk instance, from the current child nodes
func _on_remove_chunk(chunk_id):
	for child in get_children():
		# check if the child is a chunk
		var pp_chunk_node = child.get_node_or_null("PPChunkNode")

		# check if it matches the chunk_id to be removed
		if pp_chunk_node and pp_chunk_node.chunk_id == chunk_id:
			# delink the child from the parent
			remove_child(child)
			# remove the child from processing
			child.queue_free()
			print('Chunk ' + chunk_id + ' removed')
			return
	  
	print('Chunk ' + chunk_id + ' not found to remove')


func _on_pp_root_node_player_connected():
	print("----- Player connected")
	pass # Replace with function body.



func _on_pp_root_node_player_disconnected():
	print("----- Player disconnected")
	pp_root_node.authenticate_player("","")
	pass # Replace with function body.


func _on_pp_root_node_player_unauthenticated():
	print("----- Player unloged")
	pass # Replace with function body.
