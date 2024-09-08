extends Hitbox

func _on_area_3d_body_entered(body: Node3D) -> void:
	self_should_be_hit(body, 
					   self, 
					   get_parent_node_3d().get_parent_node_3d().entity_parent,
					   false, 
					   AbilityVariables.Fireball_Knockback)
	#self_should_be_hit(body == body, hitbox == self, hitbox_parent = get_parent_node_3d().get_poar)
