extends HBoxContainer

const UnitCreationDataGd    = preload("res://engine/units/UnitCreationData.gd")

var _lineIdx       setget deleted, getIdx

signal deletePressed( lineIdx )


func deleted(_a):
	assert(false)


func initialize( idx ):
	_lineIdx = idx


func setUnit( unitData : UnitCreationDataGd ):
	$"Name".text = unitData.name
	$"TextureRect".texture = unitData.icon


func onDeletePressed():
	emit_signal( "deletePressed", get_index() )


func getIdx():
	return _lineIdx

