extends Node


func sendToPlayer(playerId):
	var units = self.get_children()
	
	for unit in units:
		var unitFilename = unit.get_filename()
		var path = get_path()
		rpc_id(playerId, "insertUnit", unitFilename, path, unit.get_name())
		unit.sendToPlayer(playerId)
		
		
remote func insertUnit(unitFilename, path, name):
	var unit = load(unitFilename).instance()
	unit.set_name(name)
	get_node(path).add_child( unit )
	