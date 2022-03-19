extends RigidBody

@export var velocity = 0
@export_node_path var target_node_1
@export_node_path var target_node_2

func _ready():
	$NavigationAgent.set_target_location(get_node(target_node_1).get_global_transform().origin)
	get_node(target_node_1).show()
	get_node(target_node_2).hide()
	await get_tree().create_timer(10.5).timeout
	$NavigationAgent.set_target_location(get_node(target_node_2).get_global_transform().origin)
	get_node(target_node_1).hide()
	get_node(target_node_2).show()


func debug_path():
	var path = $NavigationAgent.get_nav_path()

	$ig.set_as_toplevel(true)
	$ig.set_global_transform(Transform())
	$ig.clear()
	$ig.begin(Mesh.PRIMITIVE_LINES)
	for i in range(path.size()-1):
		$ig.add_vertex(path[i])
		$ig.add_vertex(path[i+1])

	if path.size() == 0:
		$ig.end()
		return

	$ig.add_vertex(path[$NavigationAgent.get_nav_path_index()])
	$ig.add_vertex(path[$NavigationAgent.get_nav_path_index()]+Vector3(0, 5, 0))

	$ig.end()


func _physics_process(delta):
	var pos = get_global_transform().origin
	var target = $NavigationAgent.get_next_location()
	var vel = Vector3()
	#if $NavigationAgent.distance_to_target() > $NavigationAgent.radius:
	if true:
		var n = $RayCast.get_collision_normal()
		var abs_n = Vector3(abs(n[0]),abs(n[1]),abs(n[2]))
		var inv_floor_n = Vector3(1,1,1) - abs_n
		vel = ((target - pos) * inv_floor_n).normalized() * velocity
		print("Bef", vel)
	$NavigationAgent.set_velocity(vel)

	debug_path()


func _on_NavigationAgent_velocity_computed(safe_velocity):
	set_linear_velocity(safe_velocity)
	print("safe", safe_velocity)
