extends Node


remote func insertUnit(unitFilename, path, unitName):
	var unit = load(unitFilename).instance()
	unit.set_name(unitName)
	get_node(path).add_child( unit )
