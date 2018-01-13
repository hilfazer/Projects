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

	Network.joinGame( params["ip"], params["playerName"] )


func getGameStatus( isLive ):
	var params = {}
	params["playerName"] = Network.m_playerName
	params["ip"] = Network.m_ip
	params["isHost"] = false

	if isLive:
		pass
	else:
		SceneSwitcher.switchScene(NewGameScnPath, params)


func exitProgram():
	get_tree().quit()


