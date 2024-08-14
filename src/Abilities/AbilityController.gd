extends Node

class_name Ability

var cooldown : float = 0.0 # Cooldown time in seconds

func _init(cooldown_value : float = 0.0):
	cooldown = cooldown_value


static func use_ability(direction):
	# This method should be overridden by subclasses to define the actual ability effect.
	pass

func reset_cooldown():
	cooldown = 0.0

