extends RigidBody

onready var nav_agent : NavigationAgent = $"NavigationAgent"
export(NodePath) var targetNode


func _ready():
	var targetNodeObject : Spatial = get_node(targetNode)
	var asd = targetNodeObject.global_transform.origin
	nav_agent.set_target_location(targetNodeObject.global_transform.origin)


func _physics_process(delta):
	var currentPos = global_transform.origin
	var target = nav_agent.get_next_location()
	var velocity = target - currentPos * 10
	nav_agent.set_velocity(velocity)


func _on_NavigationAgent_velocity_computed(safe_velocity):
	set_linear_velocity(safe_velocity)
	pass # Replace with function body.
