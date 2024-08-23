extends Control
enum lobby_status {Private, Friends, Public, Invisible}
enum search_distance {Close, Default, Far, WorldWide}

@onready var steamName = $SteamName
@onready var lobbyOutput = $Chat/ChatContent
@onready var lobbyList = $LobbyList/Panel/LobbyListScroll/LobbyListVBOX
@onready var chatInput = $Send/TextEdit
@onready var chatInputGroup = $Send
@onready var chat = $Chat
@onready var lobbyPanel = $LobbyList
@onready var start = $Start


const PACKET_READ_LIMIT: int = 32

var lobby_data
var lobby_id: int = 0
var lobby_members: Array = []
var lobby_members_max: int = 10
var lobby_vote_kick: bool = false
var steam_id: int = 0
var steam_username: String = ""

func _on_close_lobby_list_pressed() -> void:
	lobbyPanel.hide()

func _on_join_pressed() -> void:
	# Set distance to worldwide
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_CLOSE)
	print("Requesting a lobby list")
	Steam.requestLobbyList()

func _on_host_pressed() -> void:
	# Make sure a lobby is not already set
	if lobby_id == 0:
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, lobby_members_max)
		
func _on_send_pressed() -> void:
	var message = chatInput.text
	var isSent = Steam.sendLobbyChatMsg(lobby_id, message)
	
	if not isSent:
		display_message("ERROR: Chat message failed to deliver")
	chatInput.text = ''
		
#####################################################################		
			
func _on_lobby_created(connect: int, this_lobby_id: int) -> void:
	if connect == 1:
		# Set the lobby ID
		lobby_id = this_lobby_id
		print("Created a lobby: %s" % lobby_id)

		# Set this lobby as joinable, just in case, though this should be done by default
		Steam.setLobbyJoinable(lobby_id, true)

		# Set some lobby data
		Steam.setLobbyData(lobby_id, "name", "VEN")
		Steam.setLobbyData(lobby_id, "mode", "STEAM")

		# Allow P2P connections to fallback to being relayed through Steam if needed
		var set_relay: bool = Steam.allowP2PPacketRelay(true)
		print("Allowing Steam to be relay backup: %s" % set_relay)
	
func join_lobby(this_lobby_id: int) -> void:
	print("Attempting to join lobby %s" % lobby_id)

	# Clear any previous lobby members lists, if you were in a previous lobby
	lobby_members.clear()

	# Make the lobby join request to Steam
	Steam.joinLobby(this_lobby_id)
	print("Joined Lobby")
	_change_to_lobby()


func _change_to_lobby() -> void:
	#Hide Lobbylist and show chat
	lobbyPanel.hide()
	chat.show()
	chatInputGroup.show()
	chatInput.show()
	
	start.show()

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
		lobby_button.connect("pressed", Callable(self, "join_lobby").bind(this_lobby))

		# Add the new lobby to the list
		lobbyList.add_child(lobby_button)
		lobbyPanel.popup()
		
func make_p2p_handshake() -> void:
	print("Sending P2P handshake to the lobby")

	#send_p2p_packet(0, {"message": "handshake", "from": steam_id})
	
func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	# If joining was successful
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		# Set this lobby ID as your lobby ID
		lobby_id = this_lobby_id

		# Get the lobby members
		get_lobby_members()

		# Make the initial handshake
		make_p2p_handshake()

	# Else it failed for some reason
	else:
		# Get the failure reason
		var fail_reason: String

		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."

		print("Failed to join this chat room: %s" % fail_reason)

		#Reopen the lobby list
		_on_join_pressed()
		
func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	# Get the lobby owner's name
	var owner_name: String = Steam.getFriendPersonaName(friend_id)

	print("Joining %s's lobby..." % owner_name)

	# Attempt to join the lobby
	join_lobby(this_lobby_id)
	
func get_lobby_members() -> void:
	# Clear your previous lobby list
	lobby_members.clear()

	# Get the number of members from this lobby from Steam
	var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)

	# Get the data of these players from Steam
	for this_member in range(0, num_of_members):
		# Get the member's Steam ID
		var member_steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, this_member)

		# Get the member's Steam name
		var member_steam_name: String = Steam.getFriendPersonaName(member_steam_id)

		# Add them to the list
		lobby_members.append({"steam_id":member_steam_id, "steam_name":member_steam_name})	
		
		
# A user's information has changed
func _on_persona_change(this_steam_id: int, _flag: int) -> void:
	# Make sure you're in a lobby and this user is valid or Steam might spam your console log
	if lobby_id > 0:
		print("A user (%s) had information change, update the lobby list" % this_steam_id)

		# Update the player list
		get_lobby_members()

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
	get_lobby_members()

func leave_lobby() -> void:
	# If in a lobby, leave it
	if lobby_id != 0:
		# Send leave request to Steam
		Steam.leaveLobby(lobby_id)

		# Wipe the Steam lobby ID then display the default lobby ID and player list title
		lobby_id = 0

		# Close session with all users
		for this_member in lobby_members:
			# Make sure this isn't your Steam ID
			if this_member['steam_id'] != steam_id:

				# Close the P2P session
				Steam.closeP2PSessionWithUser(this_member['steam_id'])

		# Clear the local lobby list
		lobby_members.clear()

func _on_lobby_data_update(success, lobbyID, memberID, key) -> void:
	print("Success: %s, LobbyID: %s, Member ID: %s, Key: %s" % [success, lobbyID, memberID, key])
	
		
func display_message(message) -> void:
	lobbyOutput.add_text("\n" + str(message))

func _on_lobby_message(result, user, message, type) -> void:
	var sender = Steam.getFriendPersonaName(user)
	display_message(str(sender) + ":" + str(message))

func _ready():
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_created.connect(_on_lobby_created)
	#Steam.lobby_data_update.connect(_on_lobby_data_update)
	#Steam.lobby_invite.connect(_on_lobby_invite)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_message.connect(_on_lobby_message)
	Steam.persona_state_change.connect(_on_persona_change)

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
