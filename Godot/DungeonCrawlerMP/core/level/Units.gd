extends Node


func sendToClient(clientId):
	var units = self.get_children()

	for unit in units:
		var unitFilename = unit.get_filename()
		var path = get_path()
		Network.RPCid( self, clientId, ["insertUnit", unitFilename, path, unit.get_name()] )
		unit.sendToClient(clientId)


remote func insertUnit(unitFilename, path, unitName):
	var unit = load(unitFilename).instance()
	unit.set_name(unitName)
	get_node(path).add_child( unit )
