extends Node3D

@export var how_many : int = 40
@export var radius : float = 10.0

func get_random_sphere_coordinate(radius : float, on_surface : bool = false, origin : Vector3 = Vector3.ZERO) -> Vector3:
	var r : float = radius
	if not on_surface:
		r = radius * pow(randf(), 1.0/3.0)
	var azimuth : float = randf_range(0.0, TAU)
	var elevation : float = acos(2.0 * randf() - 1.0)
	var x : float = r * sin(elevation) * cos(azimuth)
	var y : float = r * sin(elevation) * sin(azimuth)
	var z : float = r * cos(elevation)
	return Vector3(x, y, z) + origin

func generate() -> void:
	var mass_density : float = 7874.0
	var box : RigidBody3D = RigidBody3D.new()
	var collider : CollisionShape3D = CollisionShape3D.new()
	var dimension : Vector3 = Vector3(
		randf_range(1.0, 10.0),
		randf_range(1.0, 10.0),
		randf_range(1.0, 10.0))
	var area : float = dimension.x * dimension.y * dimension.z
	box.mass = area * mass_density
	collider.shape = BoxShape3D.new()
	collider.shape.size = dimension
	box.add_child(collider)
	var mesh_instance : MeshInstance3D = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	var mesh : BoxMesh = mesh_instance.mesh as BoxMesh
	mesh.size = dimension
	mesh.material = StandardMaterial3D.new()
	var mat : StandardMaterial3D = mesh.material
	mat.albedo_color = Color(randf(), randf(), randf())
	box.add_child(mesh_instance)
	self.add_child(box)
	box.global_position = get_random_sphere_coordinate(radius, true)

func _ready() -> void:
	for i in range(how_many):
		generate()
