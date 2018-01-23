extends Control

const NewGameScnPath = "res://gui/NewGameScene.tscn"
const LoadGameDialogScn = preload("res://gui/LoadGameDialog.tscn")


func _ready():
	Connector.connectMainMenu(self)


func newGame():
	if not get_node("Connect").validate():
		return

	var params = {}
	params["playerName"] = get_node("Connect/PlayerName").text
	params["ip"] = get_node("Connect/Ip").text
	params["isHost"] = true

	var error = Network.hostGame( params["ip"], params["playerName"] )
	if error == OK:
		SceneSwitcher.switchScene(NewGameScnPath, params)


func joinGame():
	if not get_node("Connect").validate():
		return

	var params = {}
	params["playerName"] = get_node("Connect/PlayerName").text
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


func loadGame():
	var dialog = LoadGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("hide", dialog, "queue_free")
	dialog.connect("file_selected", Connector, "loadGame")
	self.add_child(dialog)
	dialog.show()


func exitProgram():
	get_tree().quit()


