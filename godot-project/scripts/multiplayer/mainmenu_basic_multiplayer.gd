extends Control

signal init_game

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_multiplayer_connected_to_server)
	multiplayer.connection_failed.connect(_on_multiplayer_connection_failed)
	multiplayer.peer_connected.connect(_on_multiplayer_peer_connected)
	multiplayer.peer_disconnected.connect(_on_multiplayer_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_multiplayer_server_disconnected)

func create_client(ip:String, port:int) -> Error:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	if ip.is_valid_ip_address():
		var error := peer.create_client(ip, port)
		if error:
			return error 
		multiplayer.multiplayer_peer = peer
		print("Client created")
		return OK
	return FAILED

func create_server(port:int = 555555) -> Error:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error:= peer.create_server(port)
	if error:
		return error
	
	multiplayer.multiplayer_peer = peer
	print("Server created")
	return OK
	
func initialize_game():
	_send_init_game_signal.rpc()
	
@rpc("authority", "call_local")
func _send_init_game_signal():
	multiplayer.multiplayer_peer.refuse_new_connections = true
	init_game.emit()

func _on_multiplayer_connected_to_server():
	print("Connected to server")
	
func _on_multiplayer_connection_failed():
	print("Connection failed")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	
func _on_multiplayer_peer_connected(peer_id:int):
	print("peer {peerid} connected".format({peerid= peer_id}))
	
func _on_multiplayer_peer_disconnected(peer_id):
	print("peer {peerid} disconnected".format({peerid= peer_id}))
	
func _on_multiplayer_server_disconnected():
	print("Server disconnected")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
