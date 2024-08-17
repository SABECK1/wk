class_name Ghost extends Ability
var ghost = load("res://src/Abilities/Ghost/GhostDisplay.tscn")

func use_ability(user, mouse_coords):
	if not can_use_ability():
		print("Ghost on Cooldown")
		return
	print("Used Ghost")
	var g = ghost.instantiate()
	
	# Ghost should spawn at User location
	g.position = user.position
	g.configure(user, mouse_coords.position - user.position)
	
	# Adds Ghost as separate node in the tree, to unlink both Bodies
	get_node("/root").add_child(g)
	set_on_cooldown()
