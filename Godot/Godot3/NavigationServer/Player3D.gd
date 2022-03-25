extends RigidBody

onready var navAgent : NavigationAgent = $"NavigationAgent"
export(NodePath) var targetNode


func _ready():
	var targetNodeObject : Spatial = get_node(targetNode)
	var asd = targetNodeObject.global_transform.origin
	navAgent.set_target_location(targetNodeObject.global_transform.origin)


func _physics_process(delta):
	var currentPos = global_transform.origin
	var target = navAgent.get_next_location()
	var velocity = target - currentPos * 10
	navAgent.set_velocity(velocity)


func _on_NavigationAgent_velocity_computed(safe_velocity):
	set_linear_velocity(safe_velocity)
	pass # Replace with function body.
