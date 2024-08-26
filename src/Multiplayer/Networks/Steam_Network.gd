extends Node


var _hosted_lobby_id = 0
var lobby_id = 0

@onready var chat = get_node("/root/Game/MainMenu/LobbyHUD/Chat/ChatContent")


var multiplayer_scene = preload("res://src/Scenes/PlayerScenes/PlayerScene.tscn")
var multiplayer_peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()
var _players_spawn_node: Node3D
const LOBBY_NAME = "Ventior"
const LOBBY_MODE = "CoOP"

func  _ready():
	multiplayer_peer.lobby_created.connect(_on_lobby_created)
	multiplayer_peer.lobby_joined.connect(_on_lobby_joined)
	multiplayer_peer.lobby_message.connect(_on_lobby_message)
	multiplayer_peer.lobby_chat_update.connect(_on_lobby_chat_update)

	
	
func host():
	print("Starting host!")
	multiplayer_peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, 4)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)

	if not OS.has_feature("dedicated_server"):
		_add_player_to_game(1)
	
func join(lobby_id):
	print("Joining lobby %s" % lobby_id)
	multiplayer_peer.connect_lobby(lobby_id)
	multiplayer.multiplayer_peer = multiplayer_peer
	
func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	# If joining was successful
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		# Set this lobby ID as your lobby ID
		lobby_id = this_lobby_id	
		print("Joined Lobby %s" % this_lobby_id)

func _on_lobby_created(connect: int, lobby_id):
	print("On lobby created")
	if connect == 1:
		_hosted_lobby_id = lobby_id
		print("Created lobby: %s" % _hosted_lobby_id)
		
		Steam.setLobbyJoinable(_hosted_lobby_id, true)
		
		Steam.setLobbyData(_hosted_lobby_id, "name", LOBBY_NAME)
		Steam.setLobbyData(_hosted_lobby_id, "mode", LOBBY_MODE)

func list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	# NOTE: If you are using the test app id, you will need to apply a filter on your game name
	# Otherwise, it may not show up in the lobby list of your clients
	Steam.addRequestLobbyListStringFilter("name", "Ventior", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add, true)
	
func _del_player(id: int):
	print("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
	
func display_message(message) -> void:
	chat.add_text("\n" + str(message))
	
func _on_lobby_message(result, user, message, type) -> void:
	var sender = Steam.getFriendPersonaName(user)
	display_message(str(sender) + ":" + str(message))

@rpc("any_peer", "call_local")
func send_message(username, message):
	chat.text += str(username + ": ", message, "\n")

#func send_message(user, message) -> void:
	#var isSent = Steam.sendLobbyChatMsg(lobby_id, message)
	#if not isSent:
		#display_message("ERROR: Chat message failed to deliver")


func _on_lobby_chat_update(this_lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	# Get the user who has made the lobby change
	var changer_name: String = Steam.getFriendPersonaName(change_id)

	# If a player has joined the lobby
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		print("%s has joined the lobby." % changer_name)

	# Else if a player has left the lobby
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		print("%s has left the lobby." % changer_name)

	# Else if a player has been kicked
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		print("%s has been kicked from the lobby." % changer_name)

	# Else if a player has been banned
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
		print("%s has been banned from the lobby." % changer_name)

	# Else there was some unknown change
	else:
		print("%s did... something." % changer_name)

	# Update the lobby now that a change has occurred
	#get_lobby_members()
