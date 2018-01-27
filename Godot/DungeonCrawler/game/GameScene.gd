extends Node

const GameMenuScn = "res://game/GameMenu.tscn"
const LevelLoaderGd = preload("res://levels/LevelLoader.gd")
const PlayerAgentGd = preload("res://actors/PlayerAgent.gd")

enum UnitFields {PATH = 0, OWNER = 1, NODE = 2}

var m_levelLoader = LevelLoaderGd.new()  setget deleted
var m_module_                         setget deleted
var m_playerUnitsCreationData = []    setget deleted
var m_playerUnits = []                setget deleted
var m_currentLevel                    setget deleted
var m_gameMenu


signal gameStarted
signal gameEnded
signal quitGameRequested
signal saveToFileRequested( filename )


func deleted():
	assert(false)


func _enter_tree():
	var params = SceneSwitcher.getParams()
	var module_ = params[0]
	var playerUnitsData = params[1]
	assert( module_ != null == Network.isServer() )
	assert( playerUnitsData != null == Network.isServer() )
	m_module_ = module_
	m_playerUnitsCreationData = playerUnitsData

	Connector.connectGame( self )
	setPaused(true)
	if is_network_master():
		prepare()


func _ready():
	connect("quitGameRequested", self, "finish")
	connect("saveToFileRequested", self, "save")


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggleGameMenu()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		Utility.setFreeing( m_module_ )


func _input(event):
	if event.is_action_pressed("ui_select"): # TODO: remove
		self.unloadLevel( m_currentLevel )
		pass


func setPaused( enabled ):
	get_tree().set_pause(enabled)
	Utility.emit_signal("sendVariable", "Pause", "Yes" if enabled else "No")


func prepare():
	assert( Network.isServer() )

	m_playerUnits = createPlayerUnits( m_playerUnitsCreationData )
	m_currentLevel = m_levelLoader.loadLevel( m_module_.getStartingLevel(), self )
	m_levelLoader.insertPlayerUnits( m_playerUnits, m_currentLevel )

	Network.readyToStart( get_tree().get_network_unique_id() )

	for playerId in Network.m_players:
		if playerId == Network.ServerId:
			continue

		rpc_id(
			playerId, 
			"loadLevel",
			m_currentLevel.get_filename(),
			m_currentLevel.get_parent().get_path()
			)
		m_currentLevel.sendToClient(playerId)

	assignAgentsToPlayerUnits( m_playerUnits )


slave func loadLevel(filePath, nodePath):
	m_levelLoader.loadLevel(filePath, get_tree().get_root().get_node(nodePath))
	Network.rpc_id( get_network_master(), "readyToStart", get_tree().get_network_unique_id() )


remote func start():
	if is_network_master():
		rpc("start")

	setPaused(false)
	emit_signal("gameStarted")


func finish():
	emit_signal("gameEnded")


func createPlayerUnits( unitsCreationData ):
	var playerUnits = []
	for unitData in unitsCreationData:
		var unitNode_ = load( unitData["path"] ).instance()
		unitNode_.set_name( str( Network.m_players[unitData["owner"]] ) + "_" )
		unitNode_.setNameLabel( Network.m_players[unitData["owner"]] )
		playerUnits.append( {OWNER : unitData["owner"], NODE : unitNode_} )

	return playerUnits


func assignAgentsToPlayerUnits( playerUnits ):
	assert( is_network_master() )

	for unit in playerUnits:
		var ow = unit[OWNER]
		if unit[OWNER] == get_tree().get_network_unique_id():
			assignOwnAgent( unit[NODE].get_path() )
		else:
			rpc_id( unit[OWNER], "assignOwnAgent", unit[NODE].get_path() )


remote func assignOwnAgent( unitNodePath ):
	var unitNode = get_node( unitNodePath )
	assert( unitNode )
	var playerAgent = Node.new()
	playerAgent.set_network_master( get_tree().get_network_unique_id() )
	playerAgent.set_script( PlayerAgentGd )
	playerAgent.setActions( PlayerAgentGd.PlayersActions[0] )
	playerAgent.assignToUnit( unitNode )


func save( filePath ):
	var saveFile = File.new()
	if OK != saveFile.open(filePath, File.WRITE):
		return

	var saveDict = {}
	saveDict[m_currentLevel.get_name()] = m_currentLevel.save()
	

	saveFile.store_line(to_json(saveDict))
	saveFile.close()


func load(filePath):
	var saveFile = File.new()
	if not OK == saveFile.open(filePath, File.READ):
		Connector.showAcceptDialog( "File %s" % filePath + " does not exist", "No such file" )
		return

	var gameStateDict = parse_json(saveFile.get_as_text())
	var currentLevelDict = gameStateDict.values()[0]
	m_levelLoader.unloadLevel( m_currentLevel )
	m_currentLevel = m_levelLoader.loadLevel( currentLevelDict.scene, self )
	m_currentLevel.load( currentLevelDict )
	# TODO: assign player units to host
	# TODO: hide game menu


func unloadLevel( level ):
	#take player units from level
	for playerUnit in m_playerUnits:
		level.removeChildUnit( playerUnit[NODE] )

	m_levelLoader.unloadLevel( level )


func toggleGameMenu():
	if m_gameMenu == null:
		createGameMenu()
	else:
		deleteGameMenu()


func createGameMenu():
	assert( m_gameMenu == null )
	var gameMenu = preload( GameMenuScn ).instance()
	self.add_child( gameMenu )
	m_gameMenu = gameMenu


func deleteGameMenu():
	assert( m_gameMenu != null )
	m_gameMenu.queue_free()
	m_gameMenu = null