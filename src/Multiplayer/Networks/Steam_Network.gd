extends Node


var _hosted_lobby_id = 0
var lobby_id = 0

@onready var chat := get_node_or_null("/root/Game/MainMenu/LobbyHUD/Chat/ChatContent")
@onready var timer := get_node_or_null("/StartGameTimer")
@onready var root := get_node_or_null("/root/Game")
@onready var lobby := get_node_or_null("/root/Game/MultiplayerLobby")
@onready var menu := get_node_or_null("/root/Game/MainMenu")

var multiplayer_scene := preload("res://src/Scenes/PlayerScenes/PlayerScene.tscn")
var multiplayer_peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()
var _players_spawn_node: Node3D
var game_scene := preload("res://src/Scenes/Maps/MainMap.tscn")
var lobby_members = []


const LOBBY_NAME := "Ventior"
const LOBBY_MODE := "CoOP"

var timer_count := 3


func  _ready():
	multiplayer_peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_message.connect(_on_lobby_message)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	Steam.join_requested.connect(_on_lobby_join_requested)
	check_command_line()
	
	
func host():
	print("Starting host!")
	multiplayer_peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, 4)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	#if not OS.has_feature("dedicated_server"):
		
	
func join(lobby_id):
	print("Joining lobby %s" % lobby_id)
	lobby_members.clear()
	multiplayer_peer.connect_lobby(lobby_id)
	multiplayer.multiplayer_peer = multiplayer_peer
	
func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	# If joining was successful
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		# Set this lobby ID as your lobby ID
		lobby_id = this_lobby_id
		print("Joined Lobby %s" % this_lobby_id)
		get_lobby_members()
		

func _on_lobby_created(connect: int, this_lobby_id):
	print("On lobby created")
	if connect == 1:
		lobby_id = this_lobby_id
		_add_player_to_game(1)
		print("Created lobby: %s" % lobby_id)
		
		Steam.setLobbyJoinable(lobby_id, true)
		
		Steam.setLobbyData(lobby_id, "name", LOBBY_NAME)
		Steam.setLobbyData(lobby_id, "mode", LOBBY_MODE)
	  # Else it failed for some reason
	else:
		# Get the failure reason
		var fail_reason: String

		match connect:
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

func list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	# NOTE: If you are using the test app id, you will need to apply a filter on your game name
	# Otherwise, it may not show up in the lobby list of your clients
	Steam.addRequestLobbyListStringFilter("name", "Ventior", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

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
		
		lobby_members.append({"steam_id":member_steam_id, 
						  "steam_name":member_steam_name,
						  "player": null,
						  "position": GlobalSteam.SPAWN_PLATFORM[this_member],
						  "ready": false})
						
@rpc("any_peer", "call_local")	
func toggle_ready(sender_id):		
	var all_ready = true	
	for member in lobby_members:
		if member["steam_id"] == sender_id:
			member["ready"] = !member["ready"]
			# Check nach Änderung
			if member["ready"] == true:
				add_message("%s is now ready!" % member["steam_name"])
			else:
				add_message("%s is no longer ready!" % member["steam_name"])
		# Check ob alle Member ready sind
		if member["ready"] != true:
			all_ready = false
			
	if all_ready == true:
		start_timer.rpc()
	else:
		stop_timer.rpc()
		

	
@rpc("any_peer", "call_local")	
func start_timer() -> void:
	$StartGameTimer.start()
	
@rpc("any_peer", "call_local")
func stop_timer() -> void:
	$StartGameTimer.stop()
	timer_count = 3
	
func _on_start_game_timer_timeout() -> void:
	add_message.rpc("Game starting in %d seconds" % timer_count)
	if timer_count == 0:
		add_message.rpc("Starting Game, please wait...")
		$StartGameTimer.stop()
		start_game()
		return
	
	timer_count -= 1

func start_game():
	# Instantiate Game Scene
	root.add_child(game_scene.instantiate())
	
	# Hide menus
	menu.hide()
	lobby.hide()
	
	# Change cameras
	set_players_camera()
	move_players(_players_spawn_node, get_node_or_null("/root/Game/MainMap/Map/Players"))

func move_players(parent_node: Node, new_parent: Node) -> void:
	for player in parent_node.get_children():
		parent_node.remove_child(player)
		player.position.y = 1
		new_parent.add_child(player)
		player.can_move = true

func set_players_camera():
	for player in _players_spawn_node.get_children():
		player.cam = get_node("/root/Game/MainMap/MainCam")
		player.cam.make_current()

func _on_lobby_data_update(success, lobbyID, memberID):
	print("Update")
	
			
func position_players(player):
	get_lobby_members()
	var host = Steam.getLobbyOwner(lobby_id)
	for member in lobby_members:
		if member["steam_id"] == host:
			if player.name == "1":
				member["player"] == player
			else:
				continue
		
		if str(member["steam_id"]) == player.name:
			member["player"] == player	
		
		var platform = member["position"]
		player.position = platform.position + Vector3(0, 3, 5)
		player.look_at(player.position + Vector3(1, 0, 0), Vector3.UP)

	
func display_message(message) -> void:
	chat.add_text("\n" + str(message))
	
func _on_lobby_message(result, user, message, type) -> void:
	var sender = Steam.getFriendPersonaName(user)
	display_message(str(sender) + ":" + str(message))

func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	# Get the lobby owner's name
	var owner_name: String = Steam.getFriendPersonaName(friend_id)

	print("Joining %s's lobby..." % owner_name)

	# Attempt to join the lobby
	join(this_lobby_id)
	
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
			if this_member['steam_id'] != GlobalSteam.STEAM_ID:

				# Close the P2P session
				Steam.closeP2PSessionWithUser(this_member['steam_id'])

		# Clear the local lobby list
		lobby_members.clear()
		for player in _players_spawn_node.get_children():
			player.queue_free()


		

#Statusinfo not chat message
@rpc("any_peer", "call_local")
func add_message(message):
	chat.text += str(message, "\n")

func send_message(user, message) -> void:
	var isSent = Steam.sendLobbyChatMsg(lobby_id, message)
	if not isSent:
		display_message("ERROR: Chat message failed to deliver")

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
		add_message("%s has joined the lobby." % changer_name)

	# Else if a player has left the lobby
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		print("%s has left the lobby." % changer_name)
		add_message("%s has left the lobby." % changer_name)
	# Else if a player has been kicked
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		print("%s has been kicked from the lobby." % changer_name)
		add_message("%s has been kicked from the lobby." % changer_name)
	# Else if a player has been banned
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
		print("%s has been banned from the lobby." % changer_name)
		add_message("%s has been banned from the lobby." % changer_name)
	# Else there was some unknown change
	else:
		print("%s did... something." % changer_name)
		add_message("%s did... something." % changer_name)

	# Update the lobby now that a change has occurred
	get_lobby_members()

#@rpc("any_peer", "call_local")
func _add_player_to_game(id: int):
	
	print("Player %s joined the game!" % id)

	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.name = str(id)
	if id == 1:
		player_to_add.is_host = true
	player_to_add.steam_id = GlobalSteam.STEAM_ID
	
	_players_spawn_node.add_child(player_to_add, true)
	return player_to_add
	
func _del_player(id: int):
	print("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()


func check_command_line() -> void:
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
				join(int(these_arguments[1]))
