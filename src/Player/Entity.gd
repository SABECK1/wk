extends CharacterBody3D
class_name Entity
#
func _enter_tree():
	set_multiplayer_authority(name.to_int())

func load_ability(name : String, use_key : String, cooldown_value : float):
	var scene = load("res://src/Abilities/" + name + "/" + name + ".tscn")
	var new_ability: Ability = scene.instantiate()
	new_ability.ability_trigger = use_key
	new_ability.base_cooldown = cooldown_value
	add_child(new_ability)
	return new_ability
