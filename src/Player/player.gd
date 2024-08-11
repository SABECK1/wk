extends CharacterBody3D
var target_velocity = Vector3.ZERO
# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

func _physics_process(delta):
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
