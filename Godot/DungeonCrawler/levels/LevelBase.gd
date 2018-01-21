extends Node2D


func setGroundTile(tileName, x, y):
	get_node("Ground").setTile(tileName, x, y)


func sendToClient(clientId):
	get_node("Ground").sendToClient(clientId)
	get_node("Units").sendToClient(clientId)


func save():
	var saveDict = {
		scene = get_filename(),
		ground = get_node("Ground").save(),
		units = get_node("Units").save()
	}
	return saveDict


func load(saveDict):
	get_node("Ground").load(saveDict["ground"])
	get_node("Units").load(saveDict["units"])


func removeChildUnit( unitNode ):
	assert( get_node("Units").has_node( unitNode.get_path() ) )
	get_node("Units").remove_child( unitNode )


