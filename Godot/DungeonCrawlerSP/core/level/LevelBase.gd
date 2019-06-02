extends Node
class_name LevelBase

onready var _ground = $"Ground"        setget deleted
onready var _units = $"Units"          setget deleted
onready var _fog = $"FogOfWar"         setget deleted
onready var _entrances = $"Entrances"  setget deleted


func deleted(_a):
	assert(false)


signal predelete()


func _init():
	Debug.updateVariable( "Level count", +1, true )


func _ready():
	applyFogToLevel( _fog.fillTile )
	update()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal( "predelete" )
		Debug.updateVariable( "Level count", -1, true )


func setGroundTile( tileName, x, y ):
	_ground.setTile( tileName, x, y )


func removeChildUnit( unitNode ):
	assert( _units.has_node( unitNode.get_path() ) )
	_units.remove_child( unitNode )


func findEntranceWithAllUnits( unitNodes ) -> Area2D:
	var entranceWithUnits = findEntranceWithAnyUnit( unitNodes )

	if entranceWithUnits:
		if Utility.isSuperset( entranceWithUnits.get_overlapping_bodies(), unitNodes ):
			return entranceWithUnits
		else:
			return null
	else:
		return null


func findEntranceWithAnyUnit( unitNodes ) -> Area2D:
	var entrances : Array = _entrances.get_children()

	var entranceWithAnyUnits : Area2D = null
	for entrance in entrances:
		if entranceWithAnyUnits != null:
			break

		for body in entrance.get_overlapping_bodies():
			if unitNodes.has( body ):
				entranceWithAnyUnits = entrance
				break

	return entranceWithAnyUnits


func applyFogToLevel( fogTileType : int ):
	_fog.fillRectWithTile( _calculateLevelRect( _fog.cell_size ), fogTileType )


func addUnitToFogVision( unit : UnitBase ) -> int:
	if not _units.has_node( unit.name ):
		Debug.warn( self, "Level %s has no unit %s" % [self.name, unit.name] )
		return FAILED

	var fogVision = _fog.fogVisionFromNode( unit )
	if not _fog.fogVisionFromNode( unit ):
		Debug.warn( self, "Unit %s has no fog vision" % [unit.name] )
		return FAILED

	return _fog.addFogVision( fogVision )


func removeUnitFromFogVision( unit : UnitBase ) -> int:
	if not _units.has_node( unit.name ):
		Debug.warn( self, "Level %s has no unit %s" % [self.name, unit.name] )
		return FAILED

	var fogVision = _fog.fogVisionFromNode( unit )
	if not fogVision:
		Debug.warn( self, "Unit %s has no fog vision" % [unit.name] )
		return FAILED

	return _fog.removeFogVision( fogVision )


func getFogVisions() -> Array:
	return _fog.getFogVisions()


func addUnit( unit : UnitBase ) -> int:
	if unit in _units.get_children():
		return FAILED

	_units.add_child( unit, true )
	assert( unit in _units.get_children() )

	var fogVision = _fog.fogVisionFromNode( unit )
	if not fogVision:
		return OK

	assert( not fogVision in _fog.getFogVisions() )
	addUnitToFogVision( unit )
	return OK


func removeUnit( unit : UnitBase ):
	if not unit in _units.get_children():
		return NodeGuard.new()

	var guard := NodeGuard.new( unit )
	_units.remove_child( unit )

	assert( not unit in _fog.getFogVisions() )
	assert( not unit in _units.get_children() )
	return guard


func update():
	for unit in _units.get_children():
		if _fog.fogVisionFromNode( unit ) != null:
			addUnitToFogVision( unit )


func getUnit( unitName : String ) -> UnitBase:
	assert( unitName )
	return _units.get_node_or_null( unitName )


func getAllUnits() -> Array:
	return _units.get_children()


func _calculateLevelRect( targetSize : Vector2 ) -> Rect2:
	var usedGround = $'Ground'.get_used_rect()
	var groundTargetRatio = $'Ground'.cell_size / targetSize
	usedGround.position *= groundTargetRatio
	usedGround.size *= groundTargetRatio

	var usedWalls = $'Walls'.get_used_rect()
	var wallsTargetRatio = $'Walls'.cell_size / targetSize
	usedWalls.position *= groundTargetRatio
	usedWalls.size *= groundTargetRatio

	return usedGround.merge( usedWalls )

