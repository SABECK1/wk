extends Entity
const RAY_LENGTH = 2000
var ray_origin = Vector3()
var ray_target = Vector3()


var target_velocity = Vector3.ZERO
# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var blink = load_ability("Blink")
#var blinkClass = blink.new("ability_q", 10)

var abilities = [blink]
	

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

	
func _physics_process(delta):
	var mouse_coordinates = get_cursor()
	var direction = Vector3.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed	
		
		
	velocity = target_velocity
	move_and_slide()
	
	
	if not mouse_coordinates.is_empty():
		var intersection_pos = mouse_coordinates.position
		var look_at = Vector3(intersection_pos.x, self.position.y, intersection_pos.z)
		$Body.look_at(look_at, Vector3.UP)
	
