extends Node3D
class_name Hitbox


@rpc("any_peer", "call_local")
func self_should_be_hit(body: Node3D, 
						hitbox, 
						hitbox_parent : Node3D,
						should_hit_self : bool = false, 
						knockback : float = 0.0,
						damage: int = 0) -> void:
	# You shouldn't be able to hit yourself!	
	if should_hit_self == false:
		if body.has_method("handle_hit") and body != hitbox_parent:
			body.handle_hit(hitbox, knockback, damage)
	elif body.has_method("handle_hit"):
			body.handle_hit(hitbox, knockback, damage)
		
			
