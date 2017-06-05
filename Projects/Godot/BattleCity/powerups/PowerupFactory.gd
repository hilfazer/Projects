extends Node


func makePowerup(name):
	var powerup = get_node(name)
	if powerup == null:
		return null
	else:
		return powerup.duplicate()
