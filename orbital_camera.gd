class_name OrbitalCamera extends Camera3D

const MINIMUM_RADIUS : float = 0.1
const MAXIMUM_RADIUS : float = +INF
const ELEVATION_LIMIT_EPSYLON : float = 0.01

var _radius : float = 10.0
var _azimuth : float = 0.0
var _elevation : float = 0.0

var _target : Node3D = null
var _use_target_up : bool = true

@export_range(MINIMUM_RADIUS, MAXIMUM_RADIUS, 10.0) var radius : float = 10.0:
	get():
		return _radius
	set(value):
		_radius = clampf(value, MINIMUM_RADIUS, MAXIMUM_RADIUS)
@export var azimuth : float = 0.0:
	get():
		return _azimuth
	set(value):
		_azimuth = value
@export_range(-PI/2 + ELEVATION_LIMIT_EPSYLON, PI/2 - ELEVATION_LIMIT_EPSYLON, PI/32) var elevation : float = 0.0:
	get():
		return _elevation
	set(value):
		_elevation = clampf(value, -PI/2 + ELEVATION_LIMIT_EPSYLON, PI/2 - ELEVATION_LIMIT_EPSYLON)
@export var target : Node3D = null:
	get():
		return _target
	set(value):
		_target = value
@export var use_target_up : bool = true:
	get():
		return _use_target_up
	set(value):
		_use_target_up = value

func use_current_target_basis() -> void:
	if target != null:
		self.global_basis = target.global_basis

func get_up() -> Vector3:
	if target == null or not use_target_up:
		return (self.global_basis.y).normalized()
	return (target.global_basis.y).normalized()

func get_target_tangential_forward_difference_angle() -> float:
	var cam_to_target : Vector3 = target.global_position - self.global_position
	var cam_up_component : Vector3 = cam_to_target.dot(target.global_basis.y) * target.global_basis.y
	var tangent : Vector3 = cam_to_target - cam_up_component
	if tangent.length_squared() < 1e-6:
		return 0.0
	tangent = tangent.normalized()
	var target_up : Vector3 = target.global_basis.y
	var target_forward_flat : Vector3
	target_forward_flat = target.global_basis.z - target.global_basis.z.dot(target_up) * target_up
	if target_forward_flat.length() > 0.0:
		target_forward_flat = target_forward_flat.normalized()
	var angle : float = target_forward_flat.angle_to(tangent)
	var sign : float = signf(target_up.dot(target_forward_flat.cross(tangent)))
	return angle * sign

func get_target_tangential_forward_direction() -> Vector3:
	if target == null:
		return -self.global_basis.z
	var cam_to_target : Vector3 = target.global_position - self.global_position
	var cam_up_component : Vector3 = cam_to_target.dot(target.global_basis.y) * target.global_basis.y
	var tangent : Vector3 = cam_to_target - cam_up_component
	if tangent.length() > 0.0:
		return tangent.normalized()
	return -target.global_basis.z

func _update_orbital():
	if target == null:
		self.look_at(Vector3.FORWARD)
		return
	var direction : Vector3 =\
	cos(_elevation) * (cos(_azimuth) * -target.global_transform.basis.z +\
	sin(_azimuth) * target.global_transform.basis.x) +\
	sin(_elevation) * target.global_transform.basis.y
	direction = direction.normalized()

	self.look_at_from_position(
		target.global_position + radius * direction,
		target.global_position,
		get_up())

func _physics_process(delta: float) -> void:
	_update_orbital()
