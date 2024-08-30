extends Node
#@onready var spawn_platforms = get_node("/root/Game/MultiplayerLobby/Map/CSGBox3D").get_children()
#var players_in_lobby = {} # Stores information about the player and where they spawn in the lobby
#
#func _prepare_spawns():
	#var platform_index = 0
	## Store platforms in the dict so players can be assigned when joining
	#if not players_in_lobby.is_empty():
		#return
	#
	#for platform in spawn_platforms:
		#players_in_lobby[platform_index] = {"Platform" : platform, "Player" : null}
		#platform_index += 1
