extends Panel



func initialize(module):
	if module == null:
		return

	for unitPath in module.getUnitsForCreation():
		get_node("UnitChoice").add_item(unitPath)
