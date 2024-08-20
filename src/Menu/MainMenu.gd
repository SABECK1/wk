extends Control

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"
var peer = ENetMultiplayerPeer.new()
@export var dummy_player: PackedScene 

var players_in_lobby = {} # Stores information about the player and where they spawn in the lobby
const max_player_count = 4 # Keeps track of players in the lobby
@onready var spawn_platforms = get_node("/root/Game/MultiplayerLobby/Map/CSGBox3D").get_children()

#@onready var cam = get_node("/root/Game/MultiplayerLobby/MainCam")

func _ready():
	var platform_index = 0
	# Store platforms in the dict so players can be assigned when joining
	for platform in spawn_platforms:
		players_in_lobby[platform_index] = {"Platform" : platform, "Player" : null}
		platform_index += 1

func _on_host_pressed():
	peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_del_player)
	
	call_deferred("_add_player", 1)
	
	
	
func _add_player(id: int):
	print("Player %s joined the game!" % id)
	var player = dummy_player.instantiate()
	player.name = str(id)
	call_deferred("_add_player_to_lobby", player)

func _add_player_to_lobby(player : Node):
	var _player_spawn_node = get_node("/root/Game/MultiplayerLobby/Map/Players")
	_player_spawn_node.add_child(player)
	for i in max_player_count:
		if players_in_lobby[i]["Player"] != null:
			continue
		players_in_lobby[i]["Player"] = player
		player.position = players_in_lobby[i]["Platform"].position + Vector3(0, 3, 4)
		player.look_at(player.position + Vector3(-1, 0, 0), Vector3.UP) 
		return
	
	
func _del_player(id: int):
	print("Player %s left the game!" % id)
	
	var _player_spawn_node = get_node("/root/MultiplayerLobby/Levels/Players")
	if not _player_spawn_node.get_node(str(id)):
		return
	_player_spawn_node.get_node(str(id)).queue_free()


func _on_join_pressed():
	peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	


func _on_start_pressed():
	get_tree().change_scene_to_file("res://src/Scenes/Maps/MainMap.tscn")
