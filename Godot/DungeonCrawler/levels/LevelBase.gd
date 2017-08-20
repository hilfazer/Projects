extends Node2D


func setGroundTile(tileName, x, y):
	get_node("Ground").setTile(tileName, x, y)


func sendToPlayer(playerId):
	get_node("Ground").sendToPlayer(playerId)
	get_node("Units").sendToPlayer(playerId)

