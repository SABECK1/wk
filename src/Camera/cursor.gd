extends Node3D

const RAY_LENGTH = 2000

var ray_origin = Vector3()
var ray_target = Vector3()

func _physics_process(delta):
#	Get Mousepos as Target Ray
	var mouse_pos = get_viewport().get_mouse_position()
	ray_origin = $MainCam.project_ray_origin(mouse_pos)
	ray_target = ray_origin + $MainCam.project_ray_normal(mouse_pos) * RAY_LENGTH
	
#	New Ray Object for Cursor Collision with World
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	ray_query.collide_with_areas = true
	
#	Does Mousepos intersect with worldstate?
	var space_state = get_world_3d().direct_space_state
	var intersection = space_state.intersect_ray(ray_query)
	
	if not intersection.is_empty():
		var intersection_pos = intersection.position
		var look_at = Vector3(intersection_pos.x, $Player.position.y, intersection_pos.z)
		$Player.look_at(look_at, Vector3.UP)
	
