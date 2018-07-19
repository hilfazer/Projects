extends Control

const NewGameScnPath = "res://gui/NewGameScene.tscn"
const LoadGameDialogScn = preload("res://game/serialization/LoadGameDialog.tscn")


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

	Network.joinGame( get_node("Connect/Ip").text, get_node("Connect/PlayerName").text )


func receiveGameStatus( isLive ):
	var params = {}
	params["playerName"] = Network.m_playerName
	params["ip"] = Network.m_ip
	params["isHost"] = false

	if isLive:
		pass # TODO: join live game
		Connector.createGame(null, null, true)
	else:
		SceneSwitcher.switchScene(NewGameScnPath, params)


func loadGame():
	if not get_node("Connect").validate():
		return

	var dialog = LoadGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("hide", dialog, "queue_free")
	dialog.connect("file_selected", self, "hostAndLoadGame", [get_node("Connect/Ip").text, get_node("Connect/PlayerName").text])
	self.add_child(dialog)
	dialog.show()


func hostAndLoadGame( filePath, ip, hostName ):
	if Network.hostGame( ip, hostName ) != OK:
		Utility.log( "Could not host game. IP: " + str(ip) + ", hostName: " + hostName )
		return

	Connector.loadGame( filePath )


func exitProgram():
	get_tree().quit()

