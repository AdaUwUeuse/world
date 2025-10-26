extends CharacterBody3D

const ACCELERATION_RATE : float = 6.0
const DECELERATION_RATE : float = 10.0
const WALK_SPEED : float =  5.8 #3.4 #1.78
const RUN_SPEED : float = 5.8
var azimuth : float = 0.0
var elevation : float = 0.0

var ignore_me : bool = true

func _ready() -> void:
	pass

func get_input_tangential_direction() -> Vector3:
	var dir: Vector2 = Input.get_vector(
		"player_move_left",
		"player_move_right",
		"player_move_forward",
		"player_move_back"
	)
	var m: Vector3 = Vector3.ZERO
	m += -global_transform.basis.z * dir.y
	m += global_transform.basis.x * -dir.x
	return m.normalized() if m.length() > 0 else m

func spherical_camera_positioning(delta) -> void:
	var azimuth_mod = Input.get_axis("camera_move_left", "camera_move_right")
	var elevation_mod = Input.get_axis("camera_up", "camera_down")
	var cam_speed = PI/4

	azimuth += azimuth_mod * delta * cam_speed
	elevation += elevation_mod * delta * cam_speed
	elevation = clampf(elevation, -PI/2 + 0.01, PI/2 - 0.01)

	var cam_radius = 10.0
	var cam_dir = cos(elevation) * (cos(azimuth) * -global_transform.basis.z + sin(azimuth) * global_transform.basis.x) + sin(elevation) * global_transform.basis.y
	var cam_pos = self.global_position + cam_radius * cam_dir
	
	#camera.global_position = cam_pos
	#camera.look_at(global_position + global_transform.basis.y * 1.5, global_transform.basis.y)

func update_basis(planet_origin : Vector3) -> void:
	var local_up = (global_position - planet_origin).normalized()
	var forward = -global_transform.basis.z
	forward = (forward - forward.dot(local_up) * local_up).normalized()
	var right = forward.cross(local_up).normalized()
	forward = local_up.cross(right).normalized()
	var new_basis = Basis(right, local_up, -forward)
	global_transform.basis = new_basis

func _physics_process(delta: float) -> void:
	var tangent_forward : Vector3
	var tangent_right : Vector3
	var tangent : Vector3
	var radial : Vector3
	
	self.up_direction = global_transform.basis.y

	tangent_forward = velocity.dot(-global_transform.basis.z) * -global_transform.basis.z
	tangent_right = velocity.dot(global_transform.basis.x) * global_transform.basis.x
	tangent = (tangent_forward + tangent_right)
	radial = velocity - tangent_forward - tangent_right
	
	var input_direction : Vector3 = get_input_tangential_direction()
	var tangent_velocity : Vector3 = tangent
	var desired_velocity : Vector3 = input_direction * WALK_SPEED
	if input_direction.length_squared() > 0.01:
		tangent_velocity = tangent_velocity.lerp(desired_velocity, ACCELERATION_RATE * delta)
	else:
		tangent_velocity = tangent_velocity.lerp(Vector3.ZERO, DECELERATION_RATE * delta)
	velocity += -tangent + tangent_velocity
	#velocity += get_gravity() * delta * 70.0
	velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		var jump_strength = sqrt(2.0 * get_gravity().length() * 2.0)
		velocity += jump_strength * global_transform.basis.y
		ignore_me = true
	elif is_on_floor():
		var radial_vel = velocity.dot(-global_transform.basis.y) * -global_transform.basis.y
		velocity -= radial_vel

	update_basis(Vector3(0.0, 0.0, 0.0))
	move_and_slide()
	#spherical_camera_positioning(delta)
