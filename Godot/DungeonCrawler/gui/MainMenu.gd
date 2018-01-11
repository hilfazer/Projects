extends Control

const NewGameScnPath = "res://gui/NewGame.tscn"


func _ready():
	Connector.connectMainMenu(self)


func newGame():
	var params = {}
	params["playerName"] = get_node("Connect/Name").text
	params["ip"] = get_node("Connect/Ip").text
	params["isHost"] = true

	SceneSwitcher.switchScene(NewGameScnPath, params)


func joinGame():
	var params = {}
	params["playerName"] = get_node("Connect/Name").text
	params["ip"] = get_node("Connect/Ip").text
	params["isHost"] = false

	Network.joinGame( params["ip"], params["playerName"] )

	rpc_id(Network.ServerId, "askGameStatus")

func getGameStatus( isLive ):
	pass


func exitProgram():
	get_tree().quit()


