extends Node

# Player tanks need to start with string below and have number at the end
const TankPlayerPrefix = "TankPlayer"


func makeTankForPlayer( playerIdx ):
	assert(get_node(TankPlayerPrefix + str(playerIdx)) != null)
	return get_node(TankPlayerPrefix+ str(playerIdx)).duplicate()
