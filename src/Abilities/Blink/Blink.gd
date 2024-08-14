class_name Blink extends Ability


const blink_range = 10
func use_ability(user, mouse_coords):
	if is_on_cooldown() == true:
		return
	print("Vektor:",mouse_coords.position - user.position, "User:", user.position, "Cursor:", mouse_coords.position)
	
	# When the cursor hovers directly over the player, the player should not move further than that using blink
	var maximum_distance_vector = mouse_coords.position - user.position 
	
	# Normalize Vector and multiply it by Blink range
	var direction = mouse_coords.position.normalized()
	var reach = direction * blink_range
	user.position = reach + user.position
	
	set_on_cooldown()


