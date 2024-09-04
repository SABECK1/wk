extends CharacterBody3D
class_name Entity

var entity_target_velocity := Vector3.ZERO
var entity_direction := Vector3.ZERO
var entity_parent: Node3D = null
var entity_current_distance := Vector3.ZERO
var entity_knockback := 0.0
var entity_current_knockback := Vector3.ZERO 

#func _enter_tree():
	#set_multiplayer_authority(name.to_int())

func load_ability(name : String, use_key : String, cooldown_value : float):
	var scene = load("res://src/Abilities/" + name + "/" + name + ".tscn")
	var new_ability: Ability = scene.instantiate()
	new_ability.ability_trigger = use_key
	new_ability.base_cooldown = cooldown_value
	add_child(new_ability)
	return new_ability

func configure_entity(parent: Entity = null, direction: Vector3 = Vector3.ZERO, knockback_factor: float = 0.0):
	pass
	
func handle_hit(ability: Entity):
	var knockback_source_position := Vector3.ZERO
	var knockback_direction := knockback_source_position.direction_to(self.global_position)
	knockback_direction.y = 0
	
	var knockback_strength = ability.entity_knockback 

	entity_current_knockback = knockback_direction * knockback_strength
	
