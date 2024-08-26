extends Node

enum MULTIPLAYER_NETWORK_TYPE {ENET, STEAM}

@export var _players_spawn_node: Node3D

var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.STEAM
var enet_network := preload("res://src/Scenes/Multiplayer/Network/enet_network.tscn")
var steam_network := preload("res://src/Scenes/Multiplayer/Network/steam_network.tscn")
var active_network



@onready var username = get_node("/root/Game/MainMenu/Username")



func _build_multiplayer_network():
	if active_network:
		return
	match active_network_type:
		MULTIPLAYER_NETWORK_TYPE.ENET:
			print("Networktype = ENET")
			_set_active_network(enet_network)
		MULTIPLAYER_NETWORK_TYPE.STEAM:
			print("Networktype = STEAM")
			username.hide()
			_set_active_network(steam_network)
			GlobalSteam.initialize_steam()

func _set_active_network(active_network_scene):
	var network_scene_initialized = active_network_scene.instantiate()
	active_network = network_scene_initialized
	active_network._players_spawn_node = _players_spawn_node
	add_child(active_network)

func host() -> void:
	_build_multiplayer_network()
	active_network.host()
	
func join(lobby_id = 0) -> void:
	_build_multiplayer_network()
	if active_network_type != MULTIPLAYER_NETWORK_TYPE.ENET:
		active_network.list_lobbies()
	#active_network.join(lobby_id)
	
func join_lobby(lobby_id = 0) -> void:
	_build_multiplayer_network()
	active_network.join(lobby_id)
	
func send_message(message = '') -> void:
	_build_multiplayer_network()
	#if active_network_type == MULTIPLAYER_NETWORK_TYPE.ENET:
	active_network.send_message.rpc(username.text, message)
	#else:
		#active_network.send_message(username.text, message)
	

#func list_lobbies():
	#_build_multiplayer_network()
	#active_network.list_lobbies()
