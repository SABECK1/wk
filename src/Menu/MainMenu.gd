extends Control

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"
var peer = ENetMultiplayerPeer.new()
@export var main_scene: PackedScene


func _on_host_pressed():
	peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_del_player)
	_add_player(1)
	
func _add_player(id: int):
	print("Player %s joined the game!" % id)
	var player = main_scene.instantiate()
	player.name = str(id)
	var lvls = get_node("/root/Game/Levels")
	lvls.add_child(player)
	
func _del_player(id: int):
	print("Player %s left the game!" % id)

func _on_join_pressed():
	peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	
