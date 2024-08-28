extends Control
enum lobby_status {Private, Friends, Public, Invisible}
enum search_distance {Close, Default, Far, WorldWide}

##GODOTSTEAM##
@onready var steamName = $SteamName
@onready var lobbyList = $LobbyList/Panel/LobbyListScroll/LobbyListVBOX
@onready var chatInput = $LobbyHUD/Send/TextEdit
@onready var chatInputGroup = %LobbyHUD/Send
@onready var multiplayerHud = %LobbyHUD
@onready var lobbyPanel = $LobbyList
@onready var lobby = get_node("/root/Game/MultiplayerLobby")

##LOBBY##
@onready var MainMenu = self 
@export var dummy_player: PackedScene 
#@export var _player_spawn_node: Node3D
@onready var _player_spawn_node = get_node("/root/Game/MultiplayerLobby/Map/Players")

const PACKET_READ_LIMIT: int = 32

var lobby_data
var lobby_id: int = 0
var lobby_members: Array = []
var lobby_members_max: int = 10
var lobby_vote_kick: bool = false
var steam_id: int = 0
var steam_username: String = ""


func _ready():
	#Steam.join_requested.connect(_on_lobby_join_requested)
	#Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	#Steam.lobby_created.connect(_on_lobby_created)
	##Steam.lobby_data_update.connect(_on_lobby_data_update)
	##Steam.lobby_invite.connect(_on_lobby_invite)
	#Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	#Steam.lobby_message.connect(_on_lobby_message)
	#Steam.persona_state_change.connect(_on_persona_change)

func _on_close_lobby_list_pressed() -> void:
	lobbyPanel.hide()

func _on_join_pressed() -> void:
	%Network_Manager.join()
	#%MultiplayerLobbyHUD.show()


func _on_host_pressed() -> void:
	%Network_Manager.host()
	#%MultiplayerLobbyHUD.show()
		
func _on_send_pressed() -> void:
	%Network_Manager.send_message(chatInput.text)
	chatInput.text = ''

func _on_leave_pressed() -> void:
	%Network_Manager.leave()
#####################################################################		
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
		lobby_button.connect("pressed", Callable(%Network_Manager, "join_lobby").bind(this_lobby))

		# Add the new lobby to the list
		lobbyList.add_child(lobby_button)
	lobbyPanel.popup()

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

func _change_to_lobby() -> void:
	#Hide Lobbylist and show chat
	lobbyPanel.hide()
	multiplayerHud.show()

		
#func make_p2p_handshake() -> void:
	#print("Sending P2P handshake to the lobby")
#
	#send_p2p_packet(0, {"message": "handshake", "from": steam_id})
#
#func send_p2p_packet(this_target: int, packet_data: Dictionary) -> void:
			## Set the send_type and channel
	#var send_type: int = Steam.P2P_SEND_RELIABLE
	#var channel: int = 0
#
	## Create a data array to send the data through
	#var this_data: PackedByteArray
	#this_data.append_array(var_to_bytes(packet_data))
#
	## If sending a packet to everyone
	#if this_target == 0:
		## If there is more than one user, send packets
		#if lobby_members.size() > 1:
			## Loop through all members that aren't you
			#for this_member in lobby_members:
				#if this_member['steam_id'] != steam_id:
					#Steam.sendP2PPacket(this_member['steam_id'], this_data, send_type, channel)
#
	## Else send it to someone specific
	#else:
		#Steam.sendP2PPacket(this_target, this_data, send_type, channel)
		
	#
#func get_lobby_members() -> void:
	## Clear your previous lobby list
	#lobby_members.clear()
#
	## Get the number of members from this lobby from Steam
	#var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)
#
	## Get the data of these players from Steam
	#for this_member in range(0, num_of_members):
		## Get the member's Steam ID
		#var member_steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, this_member)
		##_del_all_players()
		## Get the member's Steam name
		#var member_steam_name: String = Steam.getFriendPersonaName(member_steam_id)
		#
#
		## Add them to the list
		#lobby_members.append({"steam_id":member_steam_id, 
							  #"steam_name":member_steam_name, 
							  #"player": null,
							  #"platform": spawn_platforms[this_member],
							  #"ready": false})	
							
		#_add_player.rpc(member_steam_id)
							
			#players_in_lobby = {}
	#var platform_index = 0
	## Store platforms in the dict so players can be assigned when joining
	#if not players_in_lobby.is_empty():
		#return
	#
	#for platform in spawn_platforms:
		#players_in_lobby[platform_index] = {"Platform" : platform, "Player" : null}
		#platform_index += 1
		
		
# A user's information has changed
#func _on_persona_change(this_steam_id: int, _flag: int) -> void:
	## Make sure you're in a lobby and this user is valid or Steam might spam your console log
	#if lobby_id > 0:
		#print("A user (%s) had information change, update the lobby list" % this_steam_id)
#
		## Update the player list
		#get_lobby_members()

#func _on_lobby_chat_update(this_lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	## Get the user who has made the lobby change
	#var changer_name: String = Steam.getFriendPersonaName(change_id)
#
	## If a player has joined the lobby
	#if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		#print("%s has joined the lobby." % changer_name)
#
	## Else if a player has left the lobby
	#elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		#print("%s has left the lobby." % changer_name)
#
	## Else if a player has been kicked
	#elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		#print("%s has been kicked from the lobby." % changer_name)
#
	## Else if a player has been banned
	#elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
		#print("%s has been banned from the lobby." % changer_name)
#
	## Else there was some unknown change
	#else:
		#print("%s did... something." % changer_name)
#
	## Update the lobby now that a change has occurred
	#get_lobby_members()

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

func _on_lobby_data_update(success, lobbyID, memberID) -> void:
	print("Success: %s, LobbyID: %s, Member ID: %s, Key: %s" % [success, lobbyID, memberID])
	
		


				
#@rpc("any_peer", "call_local")
#func _add_player(id: int):
	#print("Player %s joined the game!" % id)
	#if _player_spawn_node.get_node_or_null(str(id)):
		#return
#
	#var player = dummy_player.instantiate()
	#player.name = str(id)
	#_add_player_to_lobby(player)
	#_position_player(player.name)
#
#@rpc("any_peer", "call_local")
#func _position_player(player_name):
	#var user = get_node("/root/Game/MultiplayerLobby/Map/Players/%s" % player_name)
	#for lobby_member in lobby_members:
		#if lobby_member["player"] != null:
			#continue
		#lobby_member["player"] = user
		#user.position = lobby_member["platform"].position + Vector3(0, 3, 5)
		#user.look_at(user.position + Vector3(-1, 0, 0), Vector3.UP)
		#return
	#
	#
#func _add_player_to_lobby(player : Node):
	#_player_spawn_node.add_child(player)
	#
	#
#func _del_player(id: int):
	#print("Player %s left the game!" % id)
	#if not _player_spawn_node.get_node(str(id)):
		#return
	#_player_spawn_node.get_node(str(id)).queue_free()
	#
#func _del_all_players():
	#for player in _player_spawn_node.get_children():
		#player.queue_free()
