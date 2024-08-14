extends Node

class_name Ability

var base_cooldown : float # Cooldown time in seconds
var current_cooldown : float # Current Cooldown to count down
var ability_trigger : String # Key to trigger ability
func _init(use_key : String, cooldown_value : float = 0.0):
	base_cooldown = cooldown_value
	current_cooldown = 0
	ability_trigger = use_key
	

func use_ability(user : Entity, direction : Dictionary):
	# This method should be overridden by subclasses to define the actual ability effect.
	pass

func reset_cooldown():
	current_cooldown = 0.0
	
func set_on_cooldown():
	current_cooldown = base_cooldown
	
func is_on_cooldown():
	if current_cooldown > 0:
		return true
	return false
		
func get_trigger():
	return ability_trigger

