extends Node2D

@export var agentHolders : Array[NodePath] = []
var agents : Array[NavigationAgent2D]


func _ready():
	for holder in agentHolders:
		var agent = get_node(holder).get_node("NavigationAgent2D")
		if agent != null:
			agents.append(agent)
			agent.path_changed.connect(update_path_drawer)
			

func update_path_drawer():
	var paths := []
	for agent in agents:
		paths.append(agent.get_nav_path())
	$"PathsLayer/Drawer".paths = paths
	$"PathsLayer/Drawer".update()
