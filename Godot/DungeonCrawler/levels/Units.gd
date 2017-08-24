extends Node


func sendToClient(clientId):
	var units = self.get_children()
	
	for unit in units:
		var unitFilename = unit.get_filename()
		var path = get_path()
		rpc_unreliable_id(clientId, "insertUnit", unitFilename, path, unit.get_name())
		unit.sendToClient(clientId)


remote func insertUnit(unitFilename, path, name):
	var unit = load(unitFilename).instance()
	unit.set_name(name)
	get_node(path).add_child( unit )
