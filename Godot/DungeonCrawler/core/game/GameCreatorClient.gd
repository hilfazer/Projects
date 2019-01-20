extends "res://core/game/GameCreator.gd"

enum Requests { SetModule, LoadLevel, UnloadLevel, InsertUnits, Finish }

# function name and arguments
var m_functionCalls : Array = []


signal callProcessed()


func _enter_tree():
	connect( "callProcessed", self, "_processCall" )


puppet func setModuleFromFile( filepath : String ):
	_queueCall( "_setModuleFromFile", [filepath] )


puppet func loadLevel( levelName : String, levelState ):
	_queueCall( "_loadLevel", [levelName, levelState] )


puppet func createAndInsertUnits( playerUnitData : Array, entranceName : String ):
	_queueCall( "_createAndInsertUnits", [playerUnitData, entranceName] )


puppet func finalizeCreation( error : int ):
	_queueCall( "emit_signal", ["createFinished", error] )


func _queueCall( functionName : String, arguments : Array = [] ):
	m_functionCalls.append( [functionName] + arguments )
	if m_functionCalls.size() == 1:
		_processCall()


func _processCall():
	if m_functionCalls.empty():
		return

	var funcWithArgs = m_functionCalls.front()

	var result = callv( funcWithArgs.pop_front(), funcWithArgs )
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )

	m_functionCalls.pop_front()
	emit_signal( "callProcessed" )


func _setModuleFromFile( filepath : String ):
	assert( not is_network_master() )

	var module : SavingModuleGd = null

	if not filepath.empty():
		var dataResource = load( filepath )
		if dataResource != null and SavingModuleGd.verify( dataResource ):
			var moduleData = dataResource.new()
			module = SavingModuleGd.new( moduleData, dataResource.resource_path )

	yield( m_game.setCurrentModule( module ), "completed" )
