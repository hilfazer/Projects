extends Resource


func _init():
	var constMap = get_script().get_script_constant_map()

	assert( constMap.has("UnitMax") )
	assert( constMap.has("Units") )
	assert( constMap.has("LevelNames") )
	assert( constMap.has("LevelConnections") )
	assert( constMap.has("StartingLevelName") )
	assert( constMap.has("DefaultLevelEntrances") )
	assert( constMap.get("LevelNames").has( constMap.get("StartingLevelName") ) )
	assert( constMap.get("DefaultLevelEntrances").has( constMap.get("StartingLevelName") ) )
