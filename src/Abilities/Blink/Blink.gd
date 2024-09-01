class_name Blink extends Ability

var blink_range := AbilityVariables.blink_range

func use_ability(userRef, mouse_coords):
	if not can_use_ability():
		print("Blink on Cooldown")
		return
	print("Used Blink")
	
	var user = get_node(userRef)
	# When the cursor hovers directly over the player, the player should not move further than that using blink
	var maximum_distance_vector = mouse_coords.position - user.position 
	
	var direction = mouse_coords.position - user.position
	var direction_norm = direction.normalized()
	
	# If div < 1 the teleport still 
	if direction.x < 1 and direction.x > -1:
		user.position.x = user.position.x + direction.x * blink_range
	else:
		user.position.x = user.position.x + direction_norm.x * blink_range
	if direction.z < 1 and direction.z > -1:
		user.position.z = user.position.z + direction.z * blink_range
	else:
		user.position.z = user.position.z + direction_norm.z * blink_range
		
	set_on_cooldown()
	
