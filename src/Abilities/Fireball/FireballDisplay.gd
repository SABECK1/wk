extends Entity




func configure_ability(parent: Entity = null, direction: Vector3 = Vector3.ZERO):
	ability_direction = direction
	ability_parent = parent


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Ghost Movement Direction
	if ability_direction != Vector3.ZERO:
		ability_direction = ability_direction.normalized()
		
	ability_target_velocity.x = ability_direction.x * PlayerVariables.speed
	ability_target_velocity.z = ability_direction.z * PlayerVariables.speed	
	velocity = ability_target_velocity
