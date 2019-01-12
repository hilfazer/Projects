extends "res://core/game/GameCreator.gd"

enum Requests { LoadLevel, InsertUnits, Finish }

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
			var result = callv( "_loadLevel", m_requests.front()[1] )
			if result is GDScriptFunctionState:
				result = yield( result, "completed" )
		Requests.InsertUnits:
			callv( "createAndInsertUnits", m_requests.front()[1] )
		Requests.Finish:
			emit_signal( "createFinished", OK )

	m_requests.pop_front()
	emit_signal( "requestProcessed" )


func createAndInsertUnits( playerUnitData : Array, entranceName : String ):
	var playerUnits = _createPlayerUnits( playerUnitData )
	m_game.m_playerManager.setPlayerUnits( playerUnits )

	var unitNodes : Array = []
	for playerUnit in m_game.m_playerManager.m_playerUnits:
		unitNodes.append( playerUnit.m_unitNode_ )

	m_game.m_levelLoader.insertPlayerUnits( unitNodes, m_game.m_currentLevel, entranceName )
