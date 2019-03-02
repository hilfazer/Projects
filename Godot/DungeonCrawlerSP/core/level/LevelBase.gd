extends Node2D

const UtilityGd              = preload("res://core/Utility.gd")


onready var m_ground = $"Ground"       setget deleted
onready var m_units = $"Units"         setget deleted
onready var m_fog = $"FogOfWar"        setget deleted
onready var m_entrances = $"Entrances" setget deleted


func deleted(_a):
	assert(false)


signal predelete()


func _init():
	Debug.updateVariable( "Level count", +1, true )


func _ready():
	assert( m_entrances.get_child_count() > 0 )

	_applyFogOfWar( _calculateLevelRect( m_fog.cell_size ) )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal( "predelete" )
		Debug.updateVariable( "Level count", -1, true )


func setGroundTile( tileName, x, y ):
	m_ground.setTile( tileName, x, y )


func removeChildUnit( unitNode ):
	assert( m_units.has_node( unitNode.get_path() ) )
	m_units.remove_child( unitNode )


func findEntranceWithAllUnits( unitNodes ):
	var entranceWithUnits = findEntranceWithAnyUnit( unitNodes )

	if entranceWithUnits:
		if UtilityGd.isSuperset( entranceWithUnits.get_overlapping_bodies(), unitNodes ):
			return entranceWithUnits
	else:
		return null


func findEntranceWithAnyUnit( unitNodes ):
	var entrances = m_entrances.get_children()

	var entranceWithAnyUnits
	for entrance in entrances:
		if entranceWithAnyUnits != null:
			break

		for body in entrance.get_overlapping_bodies():
			if unitNodes.has( body ):
				entranceWithAnyUnits = entrance
				break

	return entranceWithAnyUnits


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


func _applyFogOfWar( rectangle : Rect2 ):
	var fogTileId = m_fog.tile_set.find_tile_by_name("black")
	for x in range(rectangle.position.x, rectangle.size.x + rectangle.position.x):
		for y in range(rectangle.position.y, rectangle.size.y + rectangle.position.y):
			m_fog.set_cell(x, y, fogTileId)

