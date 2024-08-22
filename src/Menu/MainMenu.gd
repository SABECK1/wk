extends Control
enum lobby_status {Private, Friends, Public, Invisible}
enum search_distance {Close, Default, Far, WorldWide}

@onready var steamName = $SteamName
@onready var lobbyOutput = $Chat/RichTextLabel
@onready var lobbyList = $LobbyList/Panel/LobbyListScroll/LobbyListVBOX
@onready var chatInput = $Send
@onready var lobbypanel = $LobbyList

const PACKET_READ_LIMIT: int = 32

var lobby_data
var lobby_id: int = 0
var lobby_members: Array = []
var lobby_members_max: int = 10
var lobby_vote_kick: bool = false
var steam_id: int = 0
var steam_username: String = ""


func _on_host_pressed() -> void:
	# Make sure a lobby is not already set
	if lobby_id == 0:
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, lobby_members_max)
		
func _on_lobby_created(connect: int, this_lobby_id: int) -> void:
	if connect == 1:
		# Set the lobby ID
		lobby_id = this_lobby_id
		print("Created a lobby: %s" % lobby_id)

		# Set this lobby as joinable, just in case, though this should be done by default
		Steam.setLobbyJoinable(lobby_id, true)

		# Set some lobby data
		Steam.setLobbyData(lobby_id, "name", "Gramps' Lobby")
		Steam.setLobbyData(lobby_id, "mode", "GodotSteam test")

		# Allow P2P connections to fallback to being relayed through Steam if needed
		var set_relay: bool = Steam.allowP2PPacketRelay(true)
		print("Allowing Steam to be relay backup: %s" % set_relay)

func _on_join_pressed() -> void:
	# Set distance to worldwide
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	print("Requesting a lobby list")
	Steam.requestLobbyList()

func _on_lobby_match_list(these_lobbies: Array) -> void:
	for this_lobby in these_lobbies:
		# Pull lobby data from Steam, these are specific to our example
		var lobby_name: String = Steam.getLobbyData(this_lobby, "name")
		var lobby_mode: String = Steam.getLobbyData(this_lobby, "mode")

		# Get the current number of members
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)

		# Create a button for the lobby
		var lobby_button: Button = Button.new()
		lobby_button.set_text("Lobby %s: %s [%s] - %s Player(s)" % [this_lobby, lobby_name, lobby_mode, lobby_num_members])
		lobby_button.set_size(Vector2(800, 50))
		lobby_button.set_name("lobby_%s" % this_lobby)
		#lobby_button.connect("pressed", Callable(self, "join_lobby").bind(this_lobby))

		# Add the new lobby to the list
		lobbyList.add_child(lobby_button)
		lobbypanel.popup()

func _ready():
	#Steam.join_requested.connect(_on_lobby_join_requested)
	#Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_created.connect(_on_lobby_created)
	#Steam.lobby_data_update.connect(_on_lobby_data_update)
	#Steam.lobby_invite.connect(_on_lobby_invite)
	#Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	#Steam.lobby_message.connect(_on_lobby_message)
	#Steam.persona_state_change.connect(_on_persona_change)

	# Check for command line arguments
	check_command_line()
	
	
func check_command_line():
	var these_arguments: Array = OS.get_cmdline_args()

	# There are arguments to process
	if these_arguments.size() > 0:

		# A Steam connection argument exists
		if these_arguments[0] == "+connect_lobby":

			# Lobby invite exists so try to connect to it
			if int(these_arguments[1]) > 0:

				# At this point, you'll probably want to change scenes
				# Something like a loading into lobby screen
				print("Command line lobby ID: %s" % these_arguments[1])
				#join_lobby(int(these_arguments[1]))

#const SERVER_PORT = 8080
#const SERVER_IP = "127.0.0.1"
#var peer = ENetMultiplayerPeer.new()
#
#@onready var MainMenu = self 
#@export var dummy_player: PackedScene 
#@export var _player_spawn_node: Node3D
#
#var players_in_lobby # Stores information about the player and where they spawn in the lobby
#const max_player_count = 4 # Keeps track of players in the lobby
#@onready var spawn_platforms = get_node("/root/Game/MultiplayerLobby/Map/CSGBox3D").get_children()
#
##@onready var cam = get_node("/root/Game/MultiplayerLobby/MainCam")
#@rpc("any_peer")
#func _prepare_spawns():
	#players_in_lobby = {}
	#var platform_index = 0
	## Store platforms in the dict so players can be assigned when joining
	#if not players_in_lobby.is_empty():
		#return
	#
	#for platform in spawn_platforms:
		#players_in_lobby[platform_index] = {"Platform" : platform, "Player" : null}
		#platform_index += 1
#
#func _on_host_pressed():
	#peer.create_server(SERVER_PORT)
	#multiplayer.multiplayer_peer = peer
	#multiplayer.peer_connected.connect(_add_player)
	#multiplayer.peer_disconnected.connect(_del_player)
	#_prepare_spawns()
	#call_deferred("_add_player", 1)
	#
#func _add_player(id: int):
	#print("Player %s joined the game!" % id)
	#var player = dummy_player.instantiate()
	#player.name = str(id)
	#_add_player_to_lobby(player)
	#_position_player.rpc(player.name)
#
#@rpc("any_peer", "call_local")
#func _position_player(player_name):
	#var user = get_node("/root/Game/MultiplayerLobby/Map/Players/%s" % player_name)
	#for i in max_player_count:
		#if players_in_lobby[i]["Player"] != null:
			#continue
		#players_in_lobby[i]["Player"] = user
		#user.position = players_in_lobby[i]["Platform"].position + Vector3(0, 3, 5)
		#user.look_at(user.position + Vector3(-1, 0, 0), Vector3.UP)
		#return
	#
	#
#func _add_player_to_lobby(player : Node):
	#var _player_spawn_node = get_node("/root/Game/MultiplayerLobby/Map/Players")
	#_player_spawn_node.add_child(player)
	#
	#
#func _del_player(id: int):
	#print("Player %s left the game!" % id)
	##if not _player_spawn_node.get_node(str(id)):
		##return
	##_player_spawn_node.get_node(str(id)).queue_free()
#
#
#func _on_join_pressed():
	#peer.create_client(SERVER_IP, SERVER_PORT)
	#multiplayer.multiplayer_peer = peer
	#
#
#
#func _on_start_pressed():
	#
	#get_tree().change_scene_to_file("res://src/Scenes/Maps/MainMap.tscn")
	#
