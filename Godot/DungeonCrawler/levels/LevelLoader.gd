extends Reference

const GlobalGd               = preload("res://GlobalNames.gd")

signal levelLoaded( nodeName )
signal levelUnloaded( nodeName )



func insertPlayerUnits( playerUnits, level, entranceName ):
	var spawns = getSpawnsFromEntrance( level, entranceName )

	for unit in playerUnits:

		var freeSpawn = findFreePlayerSpawn( spawns )
		if freeSpawn == null:
			continue

		spawns.erase(freeSpawn)
		level.get_node("Units").add_child( unit, true )
		unit.set_position( freeSpawn.global_position )


func getSpawnsFromEntrance( level, entranceName ):
	var spawns = []
	var entranceNode

	if entranceName == null:
		Debug.info(self, "Level entrance name unspecified. Using first entrance found.")
		entranceNode = level.get_node("Entrances").get_child(0)
	else:
		entranceNode = level.get_node("Entrances/" + entranceName)
		if entranceNode == null:
			Debug.warn(self, "Level entrance name not found. Using first entrance found.")
			entranceNode = level.get_node("Entrances").get_child(0)

	assert( entranceNode != null )
	for child in entranceNode.get_children():
		if child.is_in_group( GlobalGd.Groups.SpawnPoints ):
			spawns.append( child )

	return spawns


func findFreePlayerSpawn( spawns ):
	for spawn in spawns:
		if spawn.spawnAllowed():
			return spawn

	return null
