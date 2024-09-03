extends Entity

func configure_entity(parent: Entity = null, direction: Vector3 = Vector3.ZERO):
	entity_direction = direction
	entity_parent = parent


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Ghost Movement Direction
	if entity_direction != Vector3.ZERO:
		entity_direction = entity_direction.normalized()
		
	entity_target_velocity.x = entity_direction.x * PlayerVariables.speed
	entity_target_velocity.z = entity_direction.z * PlayerVariables.speed	
	velocity = entity_target_velocity
	
	var look_direction = entity_direction
	look_direction.z *= -1
	self.look_at(entity_direction * 2000, Vector3.UP)
	move_and_slide()

@rpc("any_peer", "call_local")
func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Hit!")
