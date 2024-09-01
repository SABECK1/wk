class_name Ghost extends Ability
var ghost = load("res://src/Abilities/Ghost/GhostDisplay.tscn")


func use_ability(userRef, mouse_coords):
	if not can_use_ability():
		print("Ghost on Cooldown")
		return 
	print("Used Ghost")
	var g = ghost.instantiate()
	
	var user = get_node(userRef)
	# Ghost should spawn at User location
	g.position = user.position
	g.configure(user, mouse_coords.position - user.position)
	
	get_node("/root/Game/MainMap/Map/Players").add_child(g)
	set_on_cooldown()
