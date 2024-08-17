extends Node

class_name Ability

var base_cooldown : float # Cooldown time in seconds
var ability_trigger : String # Key to trigger ability
var can_use : bool

func _init(use_key : String = "", cooldown_value : float = 0.5):
	base_cooldown = cooldown_value
	ability_trigger = use_key
	can_use = true
	

func use_ability(user : Entity, direction : Dictionary):
	# This method should be overridden by subclasses to define the actual ability effect.
	pass

func reset_cooldown():
	can_use = true
	
func set_on_cooldown():
	if can_use:
		can_use = false
		get_tree().create_timer(base_cooldown).timeout.connect(func(): can_use = true)
	
func can_use_ability():
	return can_use
		
func get_trigger():
	return ability_trigger
	

