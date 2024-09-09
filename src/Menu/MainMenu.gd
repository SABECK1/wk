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
@onready var lobby = get_node_or_null("/root/Game/MultiplayerLobby")

##LOBBY##
@onready var MainMenu = self 
@export var dummy_player: PackedScene 
#@export var _player_spawn_node: Node3D
@onready var _player_spawn_node = get_node_or_null("/root/Game/MultiplayerLobby/Map/Players")

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
	%LobbyHUD.show()
	lobbyPanel.hide()


func _on_host_pressed() -> void:
	%Network_Manager.host()
	%LobbyHUD.show()
	lobbyPanel.hide()
		
func _on_send_pressed() -> void:
	%Network_Manager.send_message(chatInput.text)
	chatInput.text = ''

func _on_leave_pressed() -> void:
	%Network_Manager.leave()
	%LobbyHUD.hide()
	
func _on_start_pressed() -> void:
	%Network_Manager.toggle_ready(GlobalSteam.STEAM_ID)
	
	
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

func _change_to_lobby() -> void:
	#Hide Lobbylist and show chat
	lobbyPanel.hide()
	multiplayerHud.show()
