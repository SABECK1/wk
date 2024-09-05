extends Entity

func configure_entity(parent: Entity = null, 
					  direction: Vector3 = Vector3.ZERO, 
					  knockback_factor: float = 0.0,
					  damage: int = 0):
	entity_direction = direction
	entity_parent = parent
	entity_knockback = knockback_factor
	entity_damage = damage


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
	# You shouldn't be able to hit yourself!
	if body.has_method("handle_hit") and body != entity_parent:
		body.handle_hit(self)
