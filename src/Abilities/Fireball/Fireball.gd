class_name Fireball extends Ability

@export var fireball : PackedScene

func use_ability(userRef, mouse_coords):
	if not can_use_ability():
		print("Fireball on Cooldown")
		return 
	print("Used Fireball")

	
	var user = get_node(userRef)
	
	## Ghost should spawn at User location
	#g.position = user.position
	var spawn = get_ability_spawn(user)
	
	var new_fireball = fireball.instantiate()
	new_fireball.position = spawn.position
	new_fireball.configure(user, mouse_coords.position - user.position)
	
	
	get_node("/root/Game/MainMap/Map/Players").add_child(new_fireball)
	set_on_cooldown()
