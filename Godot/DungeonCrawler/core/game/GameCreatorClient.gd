extends "res://core/game/GameCreator.gd"

enum Requests { SetModule, LoadLevel, UnloadLevel, InsertUnits, Finish }

var m_requests : Array = []


signal requestProcessed()


func _enter_tree():
	connect( "requestProcessed", self, "processRequest" )


puppet func addRequest( number : int, arguments : Array = [] ):
	m_requests.append( [number, arguments] )

	if m_requests.size() == 1:
		processRequest()


func processRequest():
	if m_requests.empty():
		return

	match m_requests.front()[0]:
		Requests.LoadLevel:
			var result = yield( callv( "_loadLevel", m_requests.front()[1] ), "completed" )
		Requests.InsertUnits:
			callv( "createAndInsertUnits", m_requests.front()[1] )
		Requests.Finish:
			emit_signal( "createFinished", OK )
		Requests.UnloadLevel:
			var result = yield( m_game.m_levelLoader.unloadLevel(), "completed" )
		Requests.SetModule:
			yield( setCurrentModuleFromFile( m_requests.front()[1][0] ), "completed" )

	m_requests.pop_front()
	emit_signal( "requestProcessed" )


func createAndInsertUnits( playerUnitData : Array, entranceName : String ):
	var playerUnits = _createPlayerUnits( playerUnitData )
	m_game.m_playerManager.setPlayerUnits( playerUnits )

	var unitNodes : Array = []
	for playerUnit in m_game.m_playerManager.m_playerUnits:
		unitNodes.append( playerUnit.m_unitNode_ )

	m_game.m_levelLoader.insertPlayerUnits( unitNodes, m_game.m_currentLevel, entranceName )


puppet func setCurrentModuleFromFile( filepath : String ):
	assert( not is_network_master() )

	var module : SavingModuleGd = null

	if not filepath.empty():
		var dataResource = load( filepath )
		if dataResource != null and SavingModuleGd.verify( dataResource ):
			var moduleData = dataResource.new()
			module = SavingModuleGd.new( moduleData, dataResource.resource_path )

	yield( m_game.setCurrentModule( module ), "completed" )
