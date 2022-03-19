extends RigidDynamicBody2D

@export var velocity = 100
@export_node_path var target_1

func _ready():
	$NavigationAgent2D.set_target_location(get_node(target_1).get_global_transform().origin)
	$NavigationAgent2D.connect("velocity_computed", on_velocity_computed)

func _physics_process(delta):
	var pos = get_global_transform().origin
	var target = $NavigationAgent2D.get_next_location()
	var vel = Vector3()
	#if $NavigationAgent2D.distance_to_target() > $NavigationAgent2D.radius:
	if true:
		vel = (target - pos).normalized() * velocity
	$NavigationAgent2D.set_velocity(vel)


func on_velocity_computed(safe_velocity):
	set_linear_velocity(safe_velocity)
	#print("safe", safe_velocity)
