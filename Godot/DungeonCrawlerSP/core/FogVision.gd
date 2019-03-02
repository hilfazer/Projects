extends Node2D

const LevelBaseGd            = preload("res://core/level/LevelBase.gd")

const Name = "FogVision"

var m_fog : TileMap = null
var m_grayTileId := 0
var _side := 8
var m_visionRect := Rect2( 0, 0, _side, _side )
var m_rectOffset = Vector2( _side / 2.0, _side / 2.0 )


func _ready():
	name = Name
	var pos : Vector2 = m_fog.world_to_map( global_position )
	pos -= m_rectOffset
	m_visionRect.position = pos
	_setTileInRect( -1, m_visionRect )


func initialize( level : LevelBaseGd ):
	m_fog = level.m_fog
	m_grayTileId = level.m_fog.tile_set.find_tile_by_name("grey")


func updateFog():
	_setTileInRect( m_grayTileId, m_visionRect )

	var pos : Vector2 = m_fog.world_to_map( global_position )
	pos -= m_rectOffset
	m_visionRect.position = pos
	_setTileInRect( -1, m_visionRect )


func _setTileInRect( tileId : int, rect : Rect2 ):
	for x in range( rect.position.x, rect.size.x + rect.position.x):
		for y in range( rect.position.y, rect.size.y + rect.position.y):
			m_fog.set_cell(x, y, tileId)

