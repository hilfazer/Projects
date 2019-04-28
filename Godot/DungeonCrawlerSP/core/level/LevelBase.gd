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
	assert( _entrances.get_child_count() > 0 )


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


func applyFogToLevel():
	_fog.applyFogOfWar( _calculateLevelRect( _fog.cell_size ) )


func addUnitToFogVision( unitNode : UnitBase ):
	if not _units.has_node( unitNode.name ):
		Debug.warn( self, "Level %s has no unit %s" % [self.name, unitNode.name] )
		return

	_fog.addUnit( unitNode )


func removeUnitFromFogVision( unitNode : UnitBase ):
	if not _units.has_node( unitNode.name ):
		Debug.warn( self, "Level %s has no unit %s" % [self.name, unitNode.name] )
		return

	_fog.removeUnit( unitNode )


func getFogVisionUnits() -> Array:
	return _fog.getFogVisionUnits()


func getUnit( unitName : String ) -> UnitBase:
	return _units.get_node( unitName ) if _units.has_node( unitName ) else null


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
