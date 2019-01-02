extends Control

const NewGameScnPath         = "res://core/gui/NewGameScene.tscn"
const LoadGameDialogScn      = preload("res://core/game/serialization/LoadGameDialog.tscn")


func _ready():
	get_tree().paused = false
	Debug.updateVariable("Pause", "No")
	assert( not get_tree().has_network_peer() )


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
	params["playerName"] = Network.m_clientName
	params["ip"] = Network.m_ip
	params["isHost"] = false

	if isLive:
		Connector.createGame( null, null )
	else:
		SceneSwitcher.switchScene( NewGameScnPath, params )


func loadGame():
	if not get_node("Connect").validate():
		return

	var dialog = LoadGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("file_selected", self, "hostAndLoadGame", [get_node("Connect/Ip").text, get_node("Connect/PlayerName").text])
	self.add_child(dialog)
	dialog.popup()
	dialog.connect("hide", dialog, "queue_free")


func hostAndLoadGame( filePath, ip, hostName ):
	if Network.hostGame( ip, hostName ) != OK:
		Debug.warn( self, "Could not host game. IP: %d, hostName: %s" % [ip, hostName] )
		return

	Connector.loadGame( filePath )


func exitProgram():
	get_tree().quit()

