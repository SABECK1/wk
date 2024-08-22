extends Node
# Steam Variables
var APP_ID = "480"
var OWNED = false
var ONLINE = false
var STEAM_ID = 0
var STEAM_NAME = ""
# Lobby Variables
var DATA
var LOBBY_ID = 0
var LOBBY_MEMBER = []
var LOBBY_INVITE_ARG = false
#
func _init():
	OS.set_environment("SteamAppID", APP_ID)
	OS.set_environment("SteamGameID", APP_ID)
#
func _ready():
	var INIT = Steam.steamInit()
	if INIT["status"] != 1:
		print("Failed to initialise Steam" + str(INIT["verbal"]) + " Shutting down...")
	
	ONLINE = Steam.loggedOn()
	STEAM_ID = Steam.getSteamID()
	STEAM_NAME = Steam.getPersonaName()
	OWNED = Steam.isSubscribed()
	#
	if !OWNED:
		print("User doesn't own this game")
		get_tree().quit()
		
		#
func _process(delta):
	Steam.run_callbacks()
