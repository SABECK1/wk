class_name HittableEntity
extends Entity
func handle_hit(ability: Entity):
	var knockback_source_position := Vector3.ZERO
	var knockback_direction := knockback_source_position.direction_to(self.global_position)
	knockback_direction.y = 0
	
	var knockback_strength = ability.entity_knockback 

	entity_current_knockback = knockback_direction * knockback_strength
