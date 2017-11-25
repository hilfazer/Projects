extends Control

const NewGameScnPath = "res://gui/NewGame.tscn"


func _ready():
	Connector.connectMainMenu(self)


func onNewGamePressed():
	var params = {}
	params["playerName"] = get_node("Connect/Name").text
	params["ip"] = get_node("Connect/Ip").text
	SceneSwitcher.switchScene(NewGameScnPath, params)
