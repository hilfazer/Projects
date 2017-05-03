extends Node

# Player spawns need to start with string below and have number at the end
const TankPlayerPrefix = "TankPlayer"


func getTankForPlayer( playerIdx ):
	assert(get_node(TankPlayerPrefix + str(playerIdx)) != null)
	return get_node(TankPlayerPrefix+ str(playerIdx)).duplicate()
