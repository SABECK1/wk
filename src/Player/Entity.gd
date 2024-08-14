extends CharacterBody3D
class_name Entity

func load_ability(name):
	var script = load("res://src/Abilities/" + name + "/" + name + ".gd")
	var scene = load("res://src/Abilities/" + name + "/" + name + ".tscn")
	var sceneNode = scene.instantiate()
	add_child(sceneNode)
	return sceneNode
