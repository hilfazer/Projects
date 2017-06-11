extends Node


func makePowerup(name):
	var powerup = get_node(name)
	if powerup == null:
		return null
	else:
		return powerup.duplicate()


func makeRandomPowerup():
	return get_child(randi() % get_child_count()).duplicate()
