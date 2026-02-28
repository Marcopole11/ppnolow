extends "res://scripts/multiplayer/mainmenu_basic_multiplayer.gd"

@onready var join_create_lobby_root: PanelContainer = $JoinCreateLobbyMenu
@onready var lobby_menu_root: Control = $LobbyMenu
@onready var client_connecting_message: Label = $JoinCreateLobbyMenu/Control/ClientConnectingMessage
@onready var join_create_lobby_menu: HBoxContainer = $JoinCreateLobbyMenu/Control/HBoxContainer

@onready var port_edit_create: LineEdit = $JoinCreateLobbyMenu/Control/HBoxContainer/CreateVBox/PortEditCreate

@onready var ip_address_edit: LineEdit = $JoinCreateLobbyMenu/Control/HBoxContainer/JoinVBox/IPAddressEdit
@onready var port_edit_join: LineEdit = $JoinCreateLobbyMenu/Control/HBoxContainer/JoinVBox/PortEditJoin

@onready var message_handler: Control = $MessageHandler

@onready var player_names_container: VBoxContainer = $LobbyMenu/PanelContainer/VBoxContainer/PlayerNames
@onready var player_name_edit: LineEdit = $LobbyMenu/ChangeNameContainer/VBoxContainer/HBoxContainer/PlayerNameEdit
@onready var start_game_button: Button = $LobbyMenu/StartGameButton

var peer_names:Dictionary[int, String] = {}

func _on_join_lobby_pressed() -> void:
	if ip_address_edit.text.is_valid_ip_address() and port_edit_join.text.is_valid_int():
		if OK == create_client(ip_address_edit.text, int(port_edit_join.text)):
			join_create_lobby_menu.visible = false
			client_connecting_message.visible = true

func _on_create_lobby_pressed() -> void:
	if port_edit_create.text.is_valid_int():
		if OK == create_server(int(port_edit_create.text)):
			join_create_lobby_root.visible = false
			lobby_menu_root.visible = true
			peer_names[multiplayer.get_unique_id()] = str(multiplayer.get_unique_id())
			_update_peer_names()

@rpc("authority", "call_local")
func inform_player_names(pPlayerNames:Dictionary[int, String]):
	peer_names = pPlayerNames
	_update_peer_names()

@rpc("any_peer", "call_local")
func change_peer_name(peer_name:String):
	peer_names[multiplayer.get_remote_sender_id()] = peer_name
	_update_peer_names()

func _on_submit_name_button_pressed() -> void:
	var newName = player_name_edit.text.strip_edges()
	
	if not newName.is_empty() and peer_names[multiplayer.get_unique_id()] != newName:
		change_peer_name.rpc(newName)

func _on_start_button_pressed() -> void:
	initialize_game()
	
func show_join_create_lobby_menu():
	join_create_lobby_root.show()
	join_create_lobby_menu.show()
	client_connecting_message.hide()
	
	lobby_menu_root.hide()

func show_lobby_menu():
	lobby_menu_root.show()
	join_create_lobby_root.hide()
	
	start_game_button.visible = multiplayer.is_server()

func show_connecting_message():
	join_create_lobby_menu.hide()
	client_connecting_message.show()

func _update_peer_names():
	var children:Array
	if peer_names.size() > player_names_container.get_child_count():
		for i in range(peer_names.size() - player_names_container.get_child_count()):
			var label = Label.new()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			player_names_container.add_child(label)
		children = player_names_container.get_children()
	elif peer_names.size() < player_names_container.get_child_count():
		children = player_names_container.get_children()
		for i in range(player_names_container.get_child_count() - peer_names.size()):
			children[-1].queue_free()
			children.remove_at(-1)
	else:
		children = player_names_container.get_children()
	
	for index in range(peer_names.size()):
		children[index].text = peer_names[peer_names.keys()[index]]

# # # # # # #
# OVERRIDES #
# # # # # # #
func _on_multiplayer_peer_connected(peer_id:int):
	super._on_multiplayer_peer_connected(peer_id)
	if multiplayer.is_server():
		peer_names[peer_id] = str(peer_id)
		inform_player_names.rpc(peer_names)
	
func _on_multiplayer_peer_disconnected(peer_id):
	super._on_multiplayer_peer_disconnected(peer_id)
	if multiplayer.is_server():
		peer_names.erase(peer_id)
		inform_player_names.rpc(peer_names)

func _on_multiplayer_connection_failed():
	super._on_multiplayer_connection_failed()
	show_join_create_lobby_menu()
	message_handler.message_text = "Cannot connect to server"
	message_handler.show()
	
func _on_multiplayer_connected_to_server():
	super._on_multiplayer_connected_to_server()
	show_lobby_menu()

func _on_multiplayer_server_disconnected():
	super._on_multiplayer_server_disconnected()
	show_join_create_lobby_menu()
	message_handler.message_text = "Server disconnected"
	message_handler.show()
