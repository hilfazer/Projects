extends Node


func sendToClient(clientId):
	var units = self.get_children()
	
	for unit in units:
		var unitFilename = unit.get_filename()
		var path = get_path()
		rpc_id(clientId, "insertUnit", unitFilename, path, unit.get_name())
		unit.sendToClient(clientId)


remote func insertUnit(unitFilename, path, unitName):
	var unit = load(unitFilename).instance()
	unit.set_name(unitName)
	get_node(path).add_child( unit )
	
	
func save():
	var saveDict = {}
	for child in get_children():
		if child.has_method("save"):
			saveDict[child.get_name()] = child.save()
	return saveDict
	
	
func load(saveDict):
	for nodeName in saveDict:
		var newUnit = load(saveDict[nodeName].scene).instance()
		newUnit.set_name(nodeName)
		add_child(newUnit)
		newUnit.load( saveDict[nodeName] )
