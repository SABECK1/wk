extends Entity

var ghost_target_velocity = Vector3.ZERO
var ghost_direction = Vector3.ZERO
var ghost_parent = null
var ghost_max_distance = 1150
var ghost_current_distance = Vector3.ZERO

func configure(parent = null, direction = null):
	ghost_parent = parent
	ghost_direction = direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Ghost Movement Direction
	if ghost_direction != Vector3.ZERO:
		ghost_direction = ghost_direction.normalized()
		
	ghost_target_velocity.x = ghost_direction.x * PlayerVariables.speed
	ghost_target_velocity.z = ghost_direction.z * PlayerVariables.speed	
	velocity = ghost_target_velocity
	
	# Ghost facing direction
	var look_direction = ghost_direction
	look_direction.z *= -1
	$Body.look_at(ghost_direction * 2000, Vector3.UP)
	
	# Ghost ability over?
	ghost_current_distance += ghost_target_velocity

	if ghost_current_distance.length() >= ghost_max_distance:
		ghost_parent.position = self.position
		self.queue_free()
	move_and_slide()
	
