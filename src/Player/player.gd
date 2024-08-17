extends Entity
const RAY_LENGTH = 2000
var ray_origin = Vector3()
var ray_target = Vector3()

var blink = load_ability("Blink", "ability_q", 10.0)
var ghost = load_ability("Ghost", "ability_e", 2.0)
#var blinkClass = blink.new("ability_q", 10)

var abilities = [blink, ghost]
	

func _unhandled_input(event):
	if event is InputEventKey:
		for action in InputMap.get_actions():
			if InputMap.action_has_event(action, event):
				for ability in abilities:
					if ability.get_trigger() == action:
						ability.use_ability(self, get_cursor())

func get_cursor():
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
	return intersection

var speed = PlayerVariables.speed

func _physics_process(delta):
	var mouse_coordinates = get_cursor()

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * PlayerVariables.speed		
		velocity.z = direction.z * PlayerVariables.speed
	else:
		velocity.x = move_toward(velocity.z, 0, PlayerVariables.speed)
		velocity.z = move_toward(velocity.z, 0, PlayerVariables.speed)
	move_and_slide()
	
	
	if not mouse_coordinates.is_empty():
		var intersection_pos = mouse_coordinates.position
		var look_at = Vector3(intersection_pos.x, self.position.y, intersection_pos.z)
		$Body.look_at(look_at, Vector3.UP)
	
