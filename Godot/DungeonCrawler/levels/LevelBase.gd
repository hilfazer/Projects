extends Node2D


func setGroundTile(tileName, x, y):
	get_node("Ground").setTile(tileName, x, y)


func sendToClient(clientId):
	get_node("Ground").sendToClient(clientId)
	get_node("Units").sendToClient(clientId)


func serialize():
	var saveDict = {
		scene = get_filename(),
		ground = get_node("Ground").serialize(),
		units = get_node("Units").serialize()
	}
	return saveDict


func deserialize(saveDict):
	get_node("Ground").deserialize(saveDict["ground"])
	get_node("Units").deserialize(saveDict["units"])


func removeChildUnit( unitNode ):
	assert( get_node("Units").has_node( unitNode.get_path() ) )
	get_node("Units").remove_child( unitNode )


