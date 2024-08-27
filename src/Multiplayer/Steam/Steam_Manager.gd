extends Node
# Steam Variables
var APP_ID = "480"
var OWNED = false
var ONLINE = false
var STEAM_ID = 0
var STEAM_NAME = ""
var PACKET_READ_LIMIT = 5
# Lobby Variables
var DATA
var LOBBY_ID = 0
var LOBBY_MEMBER = []
var LOBBY_INVITE_ARG = false
#
func _init():
	OS.set_environment("SteamAppID", APP_ID)
	OS.set_environment("SteamGameID", APP_ID)
	initialize_steam()
#
func initialize_steam():
	Steam.steamInit()
	var initialize_response: Dictionary = Steam.steamInitEx()
	print("Did Steam Initialize?: %s " % initialize_response)
	
	if initialize_response['status'] > 0:
		print("Failed to init Steam! Shutting down. %s" % initialize_response)
		get_tree().quit()
		
	OWNED = Steam.isSubscribed()
	STEAM_ID = Steam.getSteamID()
	STEAM_NAME = Steam.getPersonaName()

	print("steam_id %s" % STEAM_ID)
	
	if OWNED == false:
		print("User does not own game!")
		get_tree().quit()
		
		
func _process(delta):
	Steam.run_callbacks()
