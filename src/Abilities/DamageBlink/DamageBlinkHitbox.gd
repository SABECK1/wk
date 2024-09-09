extends Hitbox
func _on_area_3d_body_entered(body: Node3D) -> void:
	self_should_be_hit(body, 
				   self, 
				   get_owner().get_parent().get_parent().entity_parent,
				   false, 
				   AbilityVariables.damageblink_knockback,
				   AbilityVariables.damageblink_damage)
	pass
