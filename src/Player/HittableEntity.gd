class_name HittableEntity
extends Entity
var entity_current_health := 100

func handle_hit(ability: CollisionShape3D, knockback: float, damage: int = 0):
	var knockback_source_position := Vector3.ZERO
	var knockback_direction := knockback_source_position.direction_to(self.global_position)
	knockback_direction.y = 0
	var knockback_strength = knockback

	entity_current_knockback = knockback_direction * knockback_strength
	entity_current_health -= damage
